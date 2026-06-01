class NearbyVendorSerializer < ActiveModel::Serializer
  attributes :id, :name, :category, :specialty, :rating_avg, :review_count,
             :open, :latitude, :longitude,
             :distance_m, :distance_km, :distance_miles,
             :avatar_url, :city, :area

  def rating_avg
    object.rating_avg.to_f
  end

  def latitude
    object.latitude&.to_f
  end

  def longitude
    object.longitude&.to_f
  end

  def distance_m
    object.distance_m&.round(1)
  end

  def distance_km
    object.distance_m && (object.distance_m / 1_000.0).round(3)
  end

  def distance_miles
    object.distance_m && (object.distance_m / 1_609.344).round(3)
  end
end
