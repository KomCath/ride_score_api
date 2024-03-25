FactoryBot.define do
  factory :assignment do
    driver { create(:driver) }
    ride { create(:ride) }
  end
end
