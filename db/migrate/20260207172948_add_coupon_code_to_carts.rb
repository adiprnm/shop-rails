class AddCouponCodeToCarts < ActiveRecord::Migration[8.1]
  def change
    add_column :carts, :coupon_code, :string
    add_index :carts, :coupon_code
  end
end
