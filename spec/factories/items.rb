FactoryBot.define do
  factory :item do
    name { Faker::Company.name}
  end
end
