FactoryBot.define do
  factory :address do
    line1 { Faker::Address.street_address }
    line2 { [Faker::Address.secondary_address, nil].sample }
    city { Faker::Address.city }
    state { Faker::Address.state_abbr }
    zip_code { Faker::Address.zip_code.first(5) }

    trait :verified do
      verification_status { "verification_successful" }
      verified_address { "#{line1} #{line2 or ""}, #{city}, #{state} #{zip_code}-#{rand(1000..9999)}, USA" }
      coordinates { { "latitude" => Faker::Address.latitude, "longitude" => Faker::Address.longitude } }
    end
  end
end
