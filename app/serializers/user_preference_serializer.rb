class UserPreferenceSerializer < ActiveModel::Serializer
  attributes :locale, :currency, :dark_mode, :location_services,
             :notify_bookings, :notify_promotions, :notify_system
end
