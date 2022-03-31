require 'rails_helper'

RSpec.describe 'Expose Merchants API' do

  it 'sends json for a list of all merchants' do
    create_list(:merchant, 3)

    get '/api/v1/merchants'

    expect(response).to be_successful

    merchants = JSON.parse(response.body, symbolize_names: true)
    expect(merchants[:data].count).to eq(3)

    merchants[:data].each do |merchant|
      expect(merchant).to have_key(:id)
      expect(merchant).to have_key(:type)
      expect(merchant[:type]).to eq('merchant')
      expect(merchant).to have_key(:attributes)
      expect(merchant[:attributes]).to have_key(:name)
      expect(merchant[:attributes][:name]).to be_a(String)
    end
  end

  it 'can send json for one merchant' do
    merchant = create(:merchant)

    get "/api/v1/merchants/#{merchant.id}"

    expect(response).to be_successful

    json_merchant = JSON.parse(response.body, symbolize_names: true)

    expect(json_merchant).to have_key(:data)
    expect(json_merchant[:data]).to have_key(:id)
    expect(json_merchant[:data][:id]).to eq(merchant.id.to_s)
    expect(json_merchant[:data]).to have_key(:type)
    expect(json_merchant[:data]).to have_key(:attributes)
    expect(json_merchant[:data][:attributes]).to have_key(:name)
    expect(json_merchant[:data][:attributes][:name]).to be_a(String)

    bad_merchant_id = 1238532345

    get "/api/v1/merchants/#{bad_merchant_id}"

    expect(response.status).to eq(404)
  end

  it 'can send json for ALL items given a Merchant ID' do
    merchant1 = create(:merchant)
    merchant2 = create(:merchant)

    item1 = merchant1.items.create!(name: 'name1', description: 'description1', unit_price: 100.0 )
    item2 = merchant1.items.create!(name: 'name2', description: 'description2', unit_price: 100.0 )
    item3 = merchant1.items.create!(name: 'name3', description: 'description3', unit_price: 100.0 )

    item4 = merchant2.items.create!(name: 'name4', description: 'description4', unit_price: 100.0 )
    item5 = merchant2.items.create!(name: 'name5', description: 'description5', unit_price: 100.0 )

    get "/api/v1/merchants/#{merchant1.id}/items"

    expect(response).to be_successful

    json_merchant_items = JSON.parse(response.body, symbolize_names: true)

    expect(json_merchant_items).to have_key(:data)

    expect(json_merchant_items[:data]).to be_an(Array)

    json_merchant_items[:data].each do |item|
      expect(item).to have_key(:id)
      expect(item).to have_key(:type)
      expect(item).to have_key(:attributes)
      expect(item[:attributes]).to have_key(:name)
      expect(item[:attributes]).to have_key(:description)
      expect(item[:attributes]).to have_key(:unit_price)
      expect(item[:attributes]).to have_key(:merchant_id)
      expect(item[:attributes][:merchant_id]).to eq(merchant1.id)
    end
  end

  it 'finds one Merchant given a search params' do
    merchant1 = create(:merchant, name: "warhead walmart")
    merchant2 = create(:merchant, name: "amazon flex")
    merchant3 = create(:merchant, name: "hank propane")
    merchant4 = create(:merchant, name: "hank propane accesccories")

    get "/api/v1/merchants/find?name=propane"

    expect(response).to be_successful

    parsed_response = JSON.parse(response.body, symbolize_names: true)

    expect(parsed_response).to have_key(:data)
    expect(parsed_response[:data]).to have_key(:id)
    expect(parsed_response[:data]).to have_key(:type)
    expect(parsed_response[:data]).to have_key(:attributes)
    expect(parsed_response[:data][:attributes]).to have_key(:name)
    expect(parsed_response[:data][:attributes][:name]).to eq(merchant3.name)
  end

  it 'Sad path: finds one Merchant given a search params' do
    merchant1 = create(:merchant, name: "warhead walmart")
    merchant2 = create(:merchant, name: "amazon flex")
    merchant3 = create(:merchant, name: "hank propane")
    merchant4 = create(:merchant, name: "hank propane accesccories")

    get "/api/v1/merchants/find?name=safeway"

    expect(response).to be_successful

    parsed_response = JSON.parse(response.body, symbolize_names: true)

    expect(parsed_response).to have_key(:data)
    expect(parsed_response[:data]).to have_key(:message)
    expect(parsed_response[:data][:message]).to eq("Merchant not found")
  end
end
