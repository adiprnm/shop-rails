class AddTrackingNumberToOrders < ActiveRecord::Migration[8.0]
  def change
    add_column :orders, :tracking_number, :string
    add_column :orders, :tracking_number_updated_at, :datetime
  end
end
