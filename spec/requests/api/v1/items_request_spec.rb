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

  it 'can create a new Item in JSON' do
    merchant1 = create(:merchant)

    item_params = {
      name: 'item2',
      description: 'description2',
      unit_price: 150.0,
      merchant_id: merchant1.id
    }

    info_headers = {"CONTENT_TYPE" => "application/json"}

    post "/api/v1/items", headers: info_headers, params: JSON.generate(item: item_params)

    created_item = Item.last

    expect(response).to be_successful
    expect(created_item.name).to eq(item_params[:name])
    expect(created_item.description).to eq(item_params[:description])
    expect(created_item.unit_price).to eq(item_params[:unit_price])
    expect(created_item.merchant_id).to eq(item_params[:merchant_id])
  end

  it 'can delete an item' do
    merchant1 = create(:merchant)
    item_id = create(:item, merchant_id: merchant1.id).id

    expect(Item.count).to eq(1)

    delete "/api/v1/items/#{item_id}"

    expect(response).to be_successful
    expect(Item.count).to eq(0)
    expect{Item.find(item_id)}.to raise_error(ActiveRecord::RecordNotFound)
  end

  it 'can edit/update an existing item' do
    merchant1 = create(:merchant)
    item1 = create(:item, merchant_id: merchant1.id)

    updated_item_params = {name: 'Rare, Awesomely Made Graphics Card'}

    header_info = {"CONTENT_TYPE" => "application/json"}

    patch "/api/v1/items/#{item1.id}", headers: header_info, params: JSON.generate({item: updated_item_params})

    item = Item.find_by(id: item1.id)

    expect(response).to be_successful
    expect(item.name).to eq('Rare, Awesomely Made Graphics Card')
  end

  it 'sends merchant data for a given item ID' do
    merchant1 = create(:merchant)
    item1 = create(:item, merchant_id: merchant1.id)

    get "/api/v1/items/#{item1.id}/merchant"
    expect(response).to be_successful
    parsed_merchant = JSON.parse(response.body, symbolize_names: true)

    expect(parsed_merchant).to have_key(:data)
    expect(parsed_merchant[:data]).to have_key(:id)
    expect(parsed_merchant[:data][:id]).to eq(merchant1.id.to_s)
    expect(parsed_merchant[:data]).to have_key(:type)
    expect(parsed_merchant[:data]).to have_key(:attributes)
    expect(parsed_merchant[:data][:attributes]).to have_key(:name)
    expect(parsed_merchant[:data][:attributes][:name]).to eq(merchant1.name)
  end

  it 'finds all items that match search params given' do
    merchant1 = create(:merchant)
    merchant2 = create(:merchant)

    item1 = create(:item, merchant_id: merchant1.id, name: 'propane tank')
    item2 = create(:item, merchant_id: merchant1.id, name: 'propane tube')
    item3 = create(:item, merchant_id: merchant1.id, name: 'original copy of skyrim')
    item4 = create(:item, merchant_id: merchant1.id, name: 'fire starter')

    item5 = create(:item, merchant_id: merchant2.id, name: 'propane pusher')
    item6 = create(:item, merchant_id: merchant2.id, name: 'starter kit')
    item7 = create(:item, merchant_id: merchant2.id, name: '20th version of skyrim')
    item8 = create(:item, merchant_id: merchant2.id, name: 'cigarettes')

    get "/api/v1/items/find_all?name=skyrim"

    expect(response).to be_successful

    parsed_response = JSON.parse(response.body, symbolize_names: true)

    expect(parsed_response).to have_key(:data)
    expect(parsed_response[:data].count).to eq(2)
    expect(parsed_response[:data][0][:attributes][:name]).to eq('original copy of skyrim')
    expect(parsed_response[:data][1][:attributes][:name]).to eq('20th version of skyrim')

    parsed_response[:data].each do |item|
      expect(item).to have_key(:id)
      expect(item).to have_key(:type)
      expect(item).to have_key(:attributes)
      expect(item[:attributes]).to have_key(:name)
      expect(item[:attributes]).to have_key(:description)
      expect(item[:attributes]).to have_key(:unit_price)
      expect(item[:attributes]).to have_key(:merchant_id)
    end
  end

  it 'Sad Path: Finds no items that match search params given' do
    merchant1 = create(:merchant)
    merchant2 = create(:merchant)

    item1 = create(:item, merchant_id: merchant1.id, name: 'propane tank')
    item2 = create(:item, merchant_id: merchant1.id, name: 'propane tube')
    item3 = create(:item, merchant_id: merchant1.id, name: 'original copy of skyrim')
    item4 = create(:item, merchant_id: merchant1.id, name: 'fire starter')

    item5 = create(:item, merchant_id: merchant2.id, name: 'propane pusher')
    item6 = create(:item, merchant_id: merchant2.id, name: 'starter kit')
    item7 = create(:item, merchant_id: merchant2.id, name: '20th version of skyrim')
    item8 = create(:item, merchant_id: merchant2.id, name: 'cigarettes')

    get "/api/v1/items/find_all?name=noname"

    expect(response).to be_successful

    parsed_response = JSON.parse(response.body, symbolize_names: true)

    expect(parsed_response).to have_key(:data)
    expect(parsed_response[:data]).to have_key(:message)
    expect(parsed_response[:data][:message]).to eq("No items match search param")
  end
end
