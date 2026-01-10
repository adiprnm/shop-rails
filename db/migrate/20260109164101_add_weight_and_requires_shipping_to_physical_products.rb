class AddWeightAndRequiresShippingToPhysicalProducts < ActiveRecord::Migration[8.0]
  def change
    add_column :physical_products, :weight, :integer
    add_column :physical_products, :requires_shipping, :boolean
  end
end
