FactoryBot.define do
  factory :category do
    sequence(:slug)  { |n| "category-#{n}" }
    sequence(:title) { |n| "Category #{n}" }
    icon_key { "celebration" }
    tint_hex { "#FCE4EC" }
    icon_color_hex { "#C2185B" }
    cover_url { "https://example.com/cover.jpg" }
    match_keys { %w[wedding] }
    active { true }
  end
end
