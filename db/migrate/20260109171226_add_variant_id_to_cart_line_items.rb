class AddVariantIdToCartLineItems < ActiveRecord::Migration[8.0]
  def change
    add_reference :cart_line_items, :product_variant, foreign_key: true
  end
end
