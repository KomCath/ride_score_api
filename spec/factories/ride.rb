FactoryBot.define do
  factory :ride do
    start_address { [Faker::Address.latitude, Faker::Address.longitude] }
    destination_address { [Faker::Address.latitude, Faker::Address.longitude] }
  end
end
