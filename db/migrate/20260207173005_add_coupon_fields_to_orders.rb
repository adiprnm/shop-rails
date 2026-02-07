class AddCouponFieldsToOrders < ActiveRecord::Migration[8.1]
  def change
    add_column :orders, :coupon_code, :string
    add_column :orders, :coupon_discount_amount, :integer, default: 0, null: false
    add_index :orders, :coupon_code
  end
end
