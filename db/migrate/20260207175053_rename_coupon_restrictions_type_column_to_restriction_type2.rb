class RenameCouponRestrictionsTypeColumnToRestrictionType2 < ActiveRecord::Migration[8.1]
  def change
    rename_column :coupon_restrictions, :type, :restriction_kind
  end
end
