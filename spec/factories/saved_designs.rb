FactoryBot.define do
  factory :saved_design do
    association :user
    association :design
  end
end
