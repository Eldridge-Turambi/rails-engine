require 'rails_helper'

RSpec.describe 'Expose Merchants API' do

  it 'sends a list of all merchants' do
    create_list(:merchant, 3)

    get '/api/v1/merchants'

    expect(response).to be_successful
  end
end
