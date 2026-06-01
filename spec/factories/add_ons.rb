FactoryBot.define do
  factory :add_on do
    sequence(:key)   { |n| "add_on_#{n}" }
    sequence(:label) { |n| "Add-on #{n}" }
    price_cents { 500_000 }
    active { true }
  end
end
