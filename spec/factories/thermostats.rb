FactoryBot.define do
  factory :thermostat do
    household_token { Faker::Device.serial }
    location { Faker::Address.street_address }
    sequence_number { 0 }
  end
end
