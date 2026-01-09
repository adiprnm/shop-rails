class Cart < ApplicationRecord
  has_many :line_items, class_name: "CartLineItem", dependent: :delete_all
  has_many :orders

  def add_item(cartable, price = nil)
    line_item = line_items.find_or_initialize_by(cartable: cartable)
    line_item.price = price
    line_item.save!
    line_item
  end

  def remove_item(item_id)
    line_items.where(id: item_id).delete_all
  end

  def total_price
    line_items.sum { |item| item.price }
  end

  def contains_physical_product?
    line_items.any?(&:physical_product?)
  end
end
