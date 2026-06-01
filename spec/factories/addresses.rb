FactoryBot.define do
  factory :address do
    association :user
    label { "Home" }
    recipient_name { "Riya Shah" }
    line1 { "12 MG Road" }
    city  { "Pune" }
    state { "MH" }
    postal_code { "411001" }
    country { "IN" }
    phone { "+919812345678" }
  end
end
