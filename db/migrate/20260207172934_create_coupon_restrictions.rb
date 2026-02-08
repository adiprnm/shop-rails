class CreateCouponRestrictions < ActiveRecord::Migration[8.1]
  def change
    create_table :coupon_restrictions do |t|
      t.references :coupon, null: false, foreign_key: true, index: false
      t.references :restriction, polymorphic: true, null: false, index: false
      t.string :type, default: "include", null: false

      t.timestamps
    end

    add_index :coupon_restrictions, :coupon_id
    add_index :coupon_restrictions, [ :restriction_type, :restriction_id ], name: "index_coupon_restrictions_on_polymorphic"
    add_index :coupon_restrictions, [ :coupon_id, :restriction_type, :restriction_id, :type ], unique: true, name: "index_coupon_restrictions_unique"
  end
end
