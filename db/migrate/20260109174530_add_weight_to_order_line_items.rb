class AddWeightToOrderLineItems < ActiveRecord::Migration[8.0]
  def change
    add_column :order_line_items, :weight, :integer
  end
end
