class CartLineItem < ApplicationRecord
  belongs_to :cart
  belongs_to :cartable, polymorphic: true
end
