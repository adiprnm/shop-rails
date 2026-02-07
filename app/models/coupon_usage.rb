class CouponUsage < ApplicationRecord
  belongs_to :coupon
  belongs_to :order

  validates :discount_amount, presence: true

  def customer_email
    order&.customer_email_address
  end
end
