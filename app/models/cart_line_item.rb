class CartLineItem < ApplicationRecord
  belongs_to :cart
  belongs_to :cartable, polymorphic: true
  belongs_to :product_variant, optional: true

  def price
    return super if cartable.minimum_price.present?

    return product_variant.price if product_variant

    cartable.actual_price
  end

  def physical_product?
    return false unless cartable.is_a?(Product)

    cartable.physical_product?
  end
end
