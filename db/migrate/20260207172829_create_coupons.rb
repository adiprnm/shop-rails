class CreateCoupons < ActiveRecord::Migration[8.1]
  def change
    create_table :coupons do |t|
      t.string :code, null: false
      t.text :description
      t.string :discount_type, null: false
      t.integer :discount_amount
      t.datetime :starts_at
      t.datetime :expires_at
      t.integer :minimum_amount, default: 0, null: false
      t.integer :maximum_amount
      t.integer :usage_limit
      t.integer :usage_count, default: 0, null: false
      t.integer :usage_limit_per_user, default: 0, null: false
      t.boolean :exclude_sale_items, default: false, null: false
      t.string :state, default: "active", null: false

      t.timestamps
    end

    add_index :coupons, :code, unique: true
    add_index :coupons, :state
    add_index :coupons, :expires_at
  end
end
