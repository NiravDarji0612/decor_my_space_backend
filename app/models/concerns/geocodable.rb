module Geocodable
  extend ActiveSupport::Concern

  EARTH_RADIUS_METERS = 6_371_000.0

  included do
    validates :latitude,  numericality: { greater_than_or_equal_to: -90,  less_than_or_equal_to: 90  }, allow_nil: true
    validates :longitude, numericality: { greater_than_or_equal_to: -180, less_than_or_equal_to: 180 }, allow_nil: true
    validate  :coordinates_paired

    after_save :sync_geom!, if: :coordinates_changed?
  end

  class_methods do
    # Memoised check — does this model's table have a usable PostGIS geom column?
    def postgis_geom?
      return @postgis_geom if defined?(@postgis_geom)

      @postgis_geom = column_names.include?("geom") &&
                      connection.extension_enabled?("postgis")
    rescue StandardError
      @postgis_geom = false
    end

    def reset_postgis_cache!
      remove_instance_variable(:@postgis_geom) if defined?(@postgis_geom)
    end
  end

  def coordinates?
    latitude.present? && longitude.present?
  end

  private

  def coordinates_changed?
    saved_change_to_attribute?(:latitude) || saved_change_to_attribute?(:longitude)
  end

  def coordinates_paired
    return if latitude.blank? && longitude.blank?
    return if coordinates?

    errors.add(:base, "latitude and longitude must be provided together")
  end

  # Writes the PostGIS geography point via raw SQL so we don't depend on the
  # activerecord-postgis-adapter gem. No-op when PostGIS isn't available.
  def sync_geom!
    return unless self.class.postgis_geom?

    if coordinates?
      self.class.where(id: id).update_all(
        ["geom = ST_SetSRID(ST_MakePoint(?, ?), 4326)::geography", longitude.to_f, latitude.to_f]
      )
    else
      self.class.where(id: id).update_all(geom: nil)
    end
  end
end
