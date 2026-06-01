class PaymentMethodSerializer < ActiveModel::Serializer
  attributes :id, :kind, :title, :subtitle, :last4, :is_default, :expires_on
end
