require 'rails_helper'

RSpec.describe Merchant do

  describe 'relationships' do
    it { should have_many(:items)}
    it { should have_many(:invoice_items).through(:items)}

    it { should have_many(:invoices)}
    it { should have_many(:customers).through(:invoices)}
    it { should have_many(:transactions).through(:invoices)}
  end
end
