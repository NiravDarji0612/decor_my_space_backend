FactoryBot.define do
  factory :user do
    full_name { 'Jane Doe' }
    sequence(:email) { |n| "user#{n}@example.com" }
    sequence(:phone) { |n| "+1555000#{n.to_s.rjust(4, '0')}" }
    password { 'password123' }
    account_type { 'customer' }
    accepted_terms { true }

    trait :vendor do
      account_type { 'vendor' }
    end
  end
end
