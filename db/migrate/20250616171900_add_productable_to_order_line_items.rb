class AddProductableToOrderLineItems < ActiveRecord::Migration[8.0]
  def change
    add_reference :order_line_items, :productable, polymorphic: true
  end
end
