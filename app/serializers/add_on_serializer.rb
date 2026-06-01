class AddOnSerializer < ActiveModel::Serializer
  attributes :id, :key, :label, :description, :price_rupees

  def price_rupees
    object.price_cents / 100
  end
end
