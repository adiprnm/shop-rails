class AddHasPhysicalProductsToOrders < ActiveRecord::Migration[8.0]
  def change
    add_column :orders, :has_physical_products, :boolean
    add_index :orders, :has_physical_products
  end
end
