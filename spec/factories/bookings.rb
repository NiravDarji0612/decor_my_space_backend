FactoryBot.define do
  factory :booking do
    association :user
    association :design
    decorator { design.decorator }
    booking_reference { "DMS-#{SecureRandom.alphanumeric(8).upcase}" }
    event_type { "Wedding" }
    event_date { 30.days.from_now.to_date }
    time_slot { "18:00-22:00" }
    expected_guests { 200 }
    venue_name { "Taj Banquet Hall" }
    venue_address_line1 { "MG Road" }
    contact_full_name { "Riya Shah" }
    contact_phone { "+919812345678" }
    contact_email { "riya@example.com" }
    subtotal_cents { 1_000_000 }
    gst_cents { 180_000 }
    total_cents { 1_180_000 }
    advance_paid_cents { 354_000 }
    payment_method { :upi }
    payment_status { :paid }
    placed_on { Time.current }
  end
end
