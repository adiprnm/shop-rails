class CreateShippingCosts < ActiveRecord::Migration[8.0]
  def change
    create_table :shipping_costs do |t|
      t.string :origin_type
      t.integer :origin_id
      t.string :destination_type
      t.integer :destination_id
      t.integer :weight
      t.string :courier
      t.string :service
      t.string :description
      t.integer :cost
      t.string :value

      t.timestamps
    end

    add_index :shipping_costs, [ :origin_type, :origin_id, :destination_type, :destination_id, :weight, :courier, :service ], unique: true, name: "index_shipping_costs_unique"
  end
end
