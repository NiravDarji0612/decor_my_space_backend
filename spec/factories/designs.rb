FactoryBot.define do
  factory :design do
    association :decorator
    association :category
    sequence(:title) { |n| "Design #{n}" }
    description { "Beautiful setup" }
    price_cents { 1_000_000 }
    currency { "INR" }
    hero_image_url { "https://example.com/design.jpg" }
    available { true }

    trait :featured do
      featured { true }
    end

    trait :trending do
      trending { true }
    end
  end
end
