class Api::V1::SearchesController < ApplicationController

  def search_merchant
    merchant = Merchant.where("name ILIKE ?", "%#{params[:name]}%").first

    if merchant.nil?
      render json: { data: {message: 'Merchant not found'} }
    else
      render json: MerchantSerializer.new(merchant)
    end
  end

  def find_all_items
    found_items = Item.where("name ILIKE ?", "%#{params[:name]}%")

    if found_items.empty?
      render json: { data: {message: 'No items match search param'} }
    else
      render json: ItemSerializer.new(found_items)
    end
  end
end
