class AddVariantToOrderLineItems < ActiveRecord::Migration[8.0]
  def change
    add_reference :order_line_items, :product_variant, foreign_key: true
  end
end
