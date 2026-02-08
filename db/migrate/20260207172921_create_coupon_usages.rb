class CreateCouponUsages < ActiveRecord::Migration[8.1]
  def change
    create_table :coupon_usages do |t|
      t.references :coupon, null: false, foreign_key: true, index: false
      t.references :order, null: false, foreign_key: true, index: false
      t.integer :discount_amount, null: false

      t.timestamps
    end

    add_index :coupon_usages, :coupon_id
    add_index :coupon_usages, :order_id
  end
end
