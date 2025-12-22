class AddPriceToCartLineItems < ActiveRecord::Migration[8.0]
  def change
    add_column :cart_line_items, :price, :integer
  end
end
