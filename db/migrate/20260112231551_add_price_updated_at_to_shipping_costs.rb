class AddPriceUpdatedAtToShippingCosts < ActiveRecord::Migration[8.0]
  def change
    add_column :shipping_costs, :price_updated_at, :datetime
  end
end
