class RenameCartableToOrderableInOrderLineItems < ActiveRecord::Migration[8.0]
  def change
    rename_column :order_line_items, :cartable_id, :orderable_id
    rename_column :order_line_items, :cartable_type, :orderable_type
    rename_column :order_line_items, :cartable_name, :orderable_name
    rename_column :order_line_items, :cartable_price, :orderable_price
  end
end
