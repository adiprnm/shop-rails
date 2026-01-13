class AddUniqueCodeToOrders < ActiveRecord::Migration[8.0]
  def change
    add_column :orders, :unique_code, :integer
  end
end
