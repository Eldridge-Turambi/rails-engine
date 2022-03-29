class Merchant < ApplicationRecord
  has_many :items
  has_many :invoices

  has_many :invoice_items, through: :items

  has_many :customers, through: :invoices
  has_many :transactions, through: :invoices
end
