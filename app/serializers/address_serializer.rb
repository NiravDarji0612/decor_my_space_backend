class AddressSerializer < ActiveModel::Serializer
  attributes :id, :label, :recipient_name, :line1, :line2, :city, :state,
             :postal_code, :country, :phone, :is_default
end
