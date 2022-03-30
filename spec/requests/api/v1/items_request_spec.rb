require 'rails_helper'

RSpec.describe 'Expose Items API' do

  it 'sends json for a list of all items' do
    merchant1 = create(:merchant)
    merchant2 = create(:merchant)

    item1 = merchant1.items.create!(name: 'name1', description: 'description1', unit_price: 100.0 )
    item2 = merchant1.items.create!(name: 'name2', description: 'description2', unit_price: 100.0 )
    item3 = merchant1.items.create!(name: 'name3', description: 'description3', unit_price: 100.0 )

    item4 = merchant2.items.create!(name: 'name4', description: 'description4', unit_price: 100.0 )
    item5 = merchant2.items.create!(name: 'name5', description: 'description5', unit_price: 100.0 )

    get '/api/v1/items'

    expect(response).to be_successful

    all_items_json = JSON.parse(response.body, symbolize_names: true)

    expect(all_items_json).to have_key(:data)

    expect(all_items_json[:data][0][:attributes][:merchant_id]).to eq(merchant1.id)
    expect(all_items_json[:data][1][:attributes][:merchant_id]).to eq(merchant1.id)
    expect(all_items_json[:data][2][:attributes][:merchant_id]).to eq(merchant1.id)

    expect(all_items_json[:data][3][:attributes][:merchant_id]).to eq(merchant2.id)
    expect(all_items_json[:data][4][:attributes][:merchant_id]).to eq(merchant2.id)

    all_items_json[:data].each do |item|
      expect(item).to have_key(:id)
      expect(item).to have_key(:type)
      expect(item).to have_key(:attributes)
      expect(item[:attributes]).to have_key(:name)
      expect(item[:attributes]).to have_key(:description)
      expect(item[:attributes]).to have_key(:unit_price)
      expect(item[:attributes]).to have_key(:merchant_id)
      expect(item[:attributes][:unit_price]).to be_a(Float)
      expect(item[:attributes][:merchant_id]).to be_an(Integer)
    end
  end

  it 'sends json for one item (items show)' do
    merchant1 = create(:merchant)
    item1 = merchant1.items.create(name: 'name1', description: 'description1', unit_price: 100.0)

    get "/api/v1/items/#{item1.id}"

    expect(response).to be_successful

    item_parsed_json = JSON.parse(response.body, symbolize_names: true)

    expect(item_parsed_json).to have_key(:data)

    expect(item_parsed_json[:data]).to have_key(:id)
    expect(item_parsed_json[:data]).to have_key(:type)
    expect(item_parsed_json[:data]).to have_key(:attributes)

    expect(item_parsed_json[:data][:attributes]).to have_key(:name)
    expect(item_parsed_json[:data][:attributes]).to have_key(:description)
    expect(item_parsed_json[:data][:attributes]).to have_key(:unit_price)
    expect(item_parsed_json[:data][:attributes]).to have_key(:merchant_id)
    
    expect(item_parsed_json[:data][:attributes][:merchant_id]).to eq(merchant1.id)
  end
end
