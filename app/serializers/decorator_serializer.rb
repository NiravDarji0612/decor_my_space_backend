class DecoratorSerializer < ActiveModel::Serializer
  attributes :id, :name, :specialty, :tagline, :rating_avg, :review_count,
             :avatar_url, :hourly_rate_rupees, :area, :city, :phone,
             :latitude, :longitude

  attribute :rating_avg do
    object.rating_avg.to_f
  end
end
