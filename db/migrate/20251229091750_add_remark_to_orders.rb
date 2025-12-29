class AddRemarkToOrders < ActiveRecord::Migration[8.0]
  def change
    add_column :orders, :remark, :string
  end
end
