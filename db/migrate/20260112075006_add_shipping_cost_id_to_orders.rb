class AddShippingCostIdToOrders < ActiveRecord::Migration[8.0]
  def change
    add_reference :orders, :shipping_cost, foreign_key: true
  end
end
