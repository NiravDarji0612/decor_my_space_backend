FactoryBot.define do
  factory :decorator do
    sequence(:name) { |n| "Decorator #{n}" }
    specialty { "Wedding specialist" }
    hourly_rate_cents { 250_000 }
    city  { "Pune" }
    area  { "Koregaon Park" }
    phone { "+919812345678" }
    rating_avg { 4.5 }
    review_count { 10 }
    active { true }
  end
end
