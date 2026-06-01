class Decorator < ApplicationRecord
  include Geocodable

  belongs_to :user, optional: true
  has_many :designs, dependent: :destroy
  has_many :reviews, dependent: :nullify
  has_many :bookings, dependent: :nullify

  validates :name, presence: true, length: { maximum: 120 }
  validates :hourly_rate_cents, numericality: { greater_than_or_equal_to: 0 }
  validates :rating_avg, numericality: { in: 0..5 }

  scope :active,  -> { where(active: true) }
  scope :open_now, -> { where(open: true) }
  scope :nearby,  ->(city) { city.present? ? where("LOWER(city) = ?", city.downcase) : all }
  scope :with_category,   ->(c) { c.present? ? where("LOWER(category) = ?", c.to_s.downcase) : all }
  scope :with_min_rating, ->(r) { r.present? ? where("rating_avg >= ?", r.to_f) : all }

  # --- Geo scopes ----------------------------------------------------------
  # within_radius — filters by distance (meters). Uses PostGIS ST_DWithin when
  # available, otherwise a Haversine bounding-box + great-circle filter.
  scope :within_radius, ->(lat, lng, meters) {
    next none if lat.blank? || lng.blank? || meters.blank?

    lat = lat.to_f; lng = lng.to_f; meters = meters.to_f

    if postgis_geom?
      where(
        "decorators.geom IS NOT NULL AND " \
        "ST_DWithin(decorators.geom, ST_SetSRID(ST_MakePoint(?, ?), 4326)::geography, ?)",
        lng, lat, meters
      )
    else
      where("decorators.latitude IS NOT NULL AND decorators.longitude IS NOT NULL")
        .where(
          "(? * acos(LEAST(1.0, cos(radians(?)) * cos(radians(decorators.latitude)) * " \
          "cos(radians(decorators.longitude) - radians(?)) + " \
          "sin(radians(?)) * sin(radians(decorators.latitude))))) <= ?",
          Geocodable::EARTH_RADIUS_METERS, lat, lng, lat, meters
        )
    end
  }

  # Adds a virtual `distance_m` column (Float, meters) and orders by it.
  scope :with_distance_from, ->(lat, lng) {
    next all if lat.blank? || lng.blank?

    lat = lat.to_f; lng = lng.to_f

    if postgis_geom?
      distance_sql = sanitize_sql_array([
        "ST_Distance(decorators.geom, ST_SetSRID(ST_MakePoint(?, ?), 4326)::geography)",
        lng, lat
      ])
    else
      distance_sql = sanitize_sql_array([
        "(? * acos(LEAST(1.0, cos(radians(?)) * cos(radians(decorators.latitude)) * " \
        "cos(radians(decorators.longitude) - radians(?)) + " \
        "sin(radians(?)) * sin(radians(decorators.latitude)))))",
        Geocodable::EARTH_RADIUS_METERS, lat, lng, lat
      ])
    end

    select("decorators.*, (#{distance_sql}) AS distance_m").order(Arel.sql("distance_m ASC"))
  }

  def hourly_rate_rupees
    hourly_rate_cents / 100.0
  end

  # Distance attached by `with_distance_from` scope.
  def distance_m
    val = self[:distance_m]
    val.present? ? val.to_f : nil
  end

  def recompute_rating!
    stats = reviews.pick(Arel.sql("AVG(rating)"), Arel.sql("COUNT(*)"))
    update!(rating_avg: (stats[0] || 0).to_f.round(2), review_count: stats[1].to_i)
  end
end
