FactoryBot.define do
  factory :address do
    line1 { Faker::Address.street_address }
    city { Faker::Address.city }
    state { Faker::Address.state_abbr }
    zip_code { Faker::Address.zip_code.first(5) }
  end
end
