class AddProductVariantNameToOrderLineItems < ActiveRecord::Migration[8.0]
  def change
    add_column :order_line_items, :product_variant_name, :string

    reversible do |dir|
      dir.up do
        OrderLineItem.where.not(product_variant_id: nil).find_each do |line_item|
          variant = ProductVariant.find_by(id: line_item.product_variant_id)
          line_item.update_column(:product_variant_name, variant&.name)
        end
      end
    end
  end
end
