class AddQuantityToCartLineItems < ActiveRecord::Migration[8.0]
  def change
    add_column :cart_line_items, :quantity, :integer, default: 1, null: false
  end
end
