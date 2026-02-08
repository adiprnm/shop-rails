require "test_helper"

class CouponUsageTest < ActiveSupport::TestCase
  setup do
    @coupon = coupons(:active_fixed_cart)
    @order = orders(:pending_order)
  end

  test "valid with required attributes" do
    usage = CouponUsage.new(
      coupon: @coupon,
      order: @order,
      discount_amount: 5000
    )
    assert usage.valid?
  end

  test "requires discount_amount presence" do
    usage = CouponUsage.new(
      coupon: @coupon,
      order: @order,
      discount_amount: nil
    )
    assert_not usage.valid?
    assert_includes usage.errors[:discount_amount], "can't be blank"
  end

  test "requires coupon presence" do
    usage = CouponUsage.new(
      order: @order,
      discount_amount: 5000
    )
    assert_not usage.valid?
  end

  test "requires order presence" do
    usage = CouponUsage.new(
      coupon: @coupon,
      discount_amount: 5000
    )
    assert_not usage.valid?
  end

  test "customer_email returns order email" do
    usage = CouponUsage.new(
      coupon: @coupon,
      order: @order,
      discount_amount: 5000
    )

    assert_equal @order.customer_email_address, usage.customer_email
  end

  test "belongs to coupon" do
    assert_respond_to @coupon, :coupon_usages
  end

  test "belongs to order" do
    assert_respond_to @order, :coupon_usages
  end
end
