class Cart < ApplicationRecord
  has_many :line_items, class_name: "CartLineItem", dependent: :delete_all
  has_many :orders

  def add_item(cartable, price = nil, product_variant = nil, quantity = 1)
    if cartable.is_a?(Product) && cartable.physical_product?
      unless product_variant
        raise ArgumentError, "Variant must be specified for physical products"
      end
      unless product_variant.is_active
        raise ArgumentError, "Selected variant is not available"
      end
      unless product_variant.product_id == cartable.id
        raise ArgumentError, "Variant does not belong to this product"
      end
      unless product_variant.stock.positive?
        raise ArgumentError, "Selected variant is out of stock"
      end
    end

    line_item = line_items.find_or_initialize_by(cartable: cartable, product_variant: product_variant)
    line_item.price = price
    if cartable.physical_product?
      if line_item.new_record?
        line_item.quantity = quantity
      else
        line_item.quantity += quantity
      end
    end
    line_item.save!
    line_item
  end

  def remove_item(item_id)
    line_items.where(id: item_id).delete_all
  end

  def total_price
    line_items.sum { |item| item.price }
  end

  def digital_items
    line_items.reject(&:physical_product?)
  end

  def physical_items
    line_items.select(&:physical_product?)
  end

  def digital_items_total
    digital_items.sum { |item| item.price }
  end

  def physical_items_total
    physical_items.sum { |item| item.price }
  end

  def contains_physical_product?
    line_items.any?(&:physical_product?)
  end
end
