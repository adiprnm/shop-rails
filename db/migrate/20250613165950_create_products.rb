class CreateProducts < ActiveRecord::Migration[8.0]
  def change
    create_table :products do |t|
      t.string :name, null: false
      t.string :short_description
      t.text :description
      t.integer :price, null: false
      t.integer :sale_price
      t.datetime :sale_price_starts_at
      t.datetime :sale_price_ends_at
      t.string :slug, null: false
      t.integer :productable_id, null: false
      t.string :productable_type, null: false
      t.integer :state, default: 1

      t.timestamps
    end
  end
end
