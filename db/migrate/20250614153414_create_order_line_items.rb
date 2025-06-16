class CreateOrderLineItems < ActiveRecord::Migration[8.0]
  def change
    create_table :order_line_items do |t|
      t.belongs_to :order, null: false, foreign_key: true
      t.belongs_to :cartable, polymorphic: true, null: false
      t.string :cartable_name, null: false
      t.integer :cartable_price, null: false

      t.timestamps
    end
  end
end
