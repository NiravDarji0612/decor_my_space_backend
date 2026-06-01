class DesignSummarySerializer < ActiveModel::Serializer
  attributes :id, :title, :subtitle, :price_rupees, :currency, :rating_avg,
             :review_count, :hero_image_url, :available, :featured, :trending

  attribute :rating_avg do
    object.rating_avg.to_f
  end

  attribute :vendor_name do
    object.decorator&.name
  end

  attribute :category_slug do
    object.category&.slug
  end
end
