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
end
