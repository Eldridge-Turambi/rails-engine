FactoryBot.define do
  factory :item do
    name { Faker::Device.model_name}
    description { Faker::Lorem.sentence(word_count: 3)}
    unit_price { Faker::Number.number(digits: 4)}
  end
end
