class Category < ApplicationRecord
  has_and_belongs_to_many :products
  has_many :coupon_restrictions, as: :restriction, dependent: :nullify
end
