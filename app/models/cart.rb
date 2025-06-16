class Cart < ApplicationRecord
  has_many :line_items, class_name: "CartLineItem", dependent: :delete_all
  has_many :orders

  def add_item(cartable)
    line_items.find_or_create_by(cartable: cartable)
  end

  def remove_item(item_id)
    line_items.where(id: item_id).delete_all
  end

  def total_price
    line_items.sum { |item| item.cartable.actual_price }
  end
end
