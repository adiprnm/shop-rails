class CartLineItem < ApplicationRecord
  belongs_to :cart
  belongs_to :cartable, polymorphic: true

  def price
    return super if cartable.minimum_price.present?

    cartable.actual_price
  end
end
