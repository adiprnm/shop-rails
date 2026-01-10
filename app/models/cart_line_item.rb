class CartLineItem < ApplicationRecord
  belongs_to :cart
  belongs_to :cartable, polymorphic: true
  belongs_to :product_variant, optional: true

  validates :quantity, numericality: { greater_than: 0 }

  def price
    return super * quantity if cartable.minimum_price.present?

    return product_variant.price * quantity if product_variant

    cartable.actual_price * quantity
  end

  def physical_product?
    return false unless cartable.is_a?(Product)

    cartable.physical_product?
  end
end
