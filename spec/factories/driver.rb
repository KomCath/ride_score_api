FactoryBot.define do
  factory :driver do
    home_address { [Faker::Address.latitude, Faker::Address.longitude] }
  end
end
