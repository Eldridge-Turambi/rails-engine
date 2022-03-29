FactoryBot.define do
  factory :merchant do
    ## do not know why it is 'Company' and not 'Merchant'
    name { Faker::Company.name}
  end
end
