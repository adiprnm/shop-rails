require "test_helper"

class CouponRestrictionTest < ActiveSupport::TestCase
  setup do
    @coupon = coupons(:active_fixed_cart)
  end

  test "valid with required attributes" do
    product = products(:one)
    restriction = CouponRestriction.new(
      coupon: @coupon,
      restriction: product,
      type: "include"
    )
    assert restriction.valid?
  end

  test "valid with required attributes" do
    product = products(:ruby_guide)
    restriction = CouponRestriction.new(
      coupon: @coupon,
      restriction: product,
      restriction_kind: "include"
    )
    assert restriction.valid?
  end

  test "requires type presence" do
    product = products(:ruby_guide)
    restriction = CouponRestriction.new(
      coupon: @coupon,
      restriction: product,
      restriction_kind: nil
    )
    assert_not restriction.valid?
    assert_includes restriction.errors[:restriction_kind], "can't be blank"
  end

  test "requires type to be include or exclude" do
    product = products(:ruby_guide)
    restriction = CouponRestriction.new(
      coupon: @coupon,
      restriction: product,
      restriction_kind: "invalid"
    )
    assert_not restriction.valid?
    assert_includes restriction.errors[:restriction_kind], "is not included in the list"
  end

  test "requires restriction presence" do
    restriction = CouponRestriction.new(
      coupon: @coupon,
      restriction_kind: "include"
    )
    assert_not restriction.valid?
  end

  test "valid with product restriction" do
    product = products(:ruby_guide)
    restriction = CouponRestriction.new(
      coupon: @coupon,
      restriction: product,
      restriction_type: "Product",
      restriction_kind: "include"
    )
    assert_equal "Product", restriction.restriction_type
  end

  test "valid with category restriction" do
    category = categories(:programming_ebook)
    restriction = CouponRestriction.new(
      coupon: @coupon,
      restriction: category,
      restriction_type: "Category",
      restriction_kind: "exclude"
    )
    assert_equal "Category", restriction.restriction_type
  end

  test "scope include returns only include type restrictions" do
    product = products(:ruby_guide)
    restriction1 = CouponRestriction.create!(
      coupon: @coupon,
      restriction: product,
      restriction_kind: "include"
    )
    restriction2 = CouponRestriction.create!(
      coupon: @coupon,
      restriction: product,
      restriction_kind: "exclude"
    )

    assert_includes CouponRestriction.include, restriction1
    assert_not_includes CouponRestriction.include, restriction2
  end

  test "scope exclude returns only exclude type restrictions" do
    product = products(:ruby_guide)
    restriction1 = CouponRestriction.create!(
      coupon: @coupon,
      restriction: product,
      restriction_kind: "include"
    )
    restriction2 = CouponRestriction.create!(
      coupon: @coupon,
      restriction: product,
      restriction_kind: "exclude"
    )

    assert_not_includes CouponRestriction.exclude, restriction1
    assert_includes CouponRestriction.exclude, restriction2
  end

  test "scope products returns only product restrictions" do
    product = products(:ruby_guide)
    category = categories(:programming_ebook)
    product_restriction = CouponRestriction.create!(
      coupon: @coupon,
      restriction: product,
      restriction_type: "Product",
      restriction_kind: "include"
    )
    category_restriction = CouponRestriction.create!(
      coupon: @coupon,
      restriction: category,
      restriction_type: "Category",
      restriction_kind: "include"
    )

    assert_includes CouponRestriction.products, product_restriction
    assert_not_includes CouponRestriction.products, category_restriction
  end

  test "scope categories returns only category restrictions" do
    product = products(:ruby_guide)
    category = categories(:programming_ebook)
    product_restriction = CouponRestriction.create!(
      coupon: @coupon,
      restriction: product,
      restriction_type: "Product",
      restriction_kind: "include"
    )
    category_restriction = CouponRestriction.create!(
      coupon: @coupon,
      restriction: category,
      restriction_type: "Category",
      restriction_kind: "include"
    )

    assert_not_includes CouponRestriction.categories, product_restriction
    assert_includes CouponRestriction.categories, category_restriction
  end

  test "belongs to coupon" do
    assert_respond_to @coupon, :coupon_restrictions
  end

  test "belongs to restriction polymorphic" do
    product = products(:ruby_guide)
    restriction = CouponRestriction.new(
      coupon: @coupon,
      restriction: product,
      restriction_kind: "include"
    )

    assert_respond_to restriction, :restriction
  end

  test "requires type to be include or exclude" do
    product = products(:ruby_guide)
    restriction = CouponRestriction.new(
      coupon: @coupon,
      restriction: product,
      restriction_kind: "invalid"
    )
    assert_not restriction.valid?
    assert_includes restriction.errors[:restriction_kind], "is not included in the list"
  end

  test "requires restriction presence" do
    restriction = CouponRestriction.new(
      coupon: @coupon,
      restriction_kind: "include"
    )
    assert_not restriction.valid?
  end

  test "valid with product restriction" do
    product = products(:ruby_guide)
    restriction = CouponRestriction.new(
      coupon: @coupon,
      restriction: product,
      restriction_type: "Product",
      restriction_kind: "include"
    )
    assert_equal "Product", restriction.restriction_type
  end

  test "valid with category restriction" do
    category = categories(:programming_ebook)
    restriction = CouponRestriction.new(
      coupon: @coupon,
      restriction: category,
      restriction_type: "Category",
      restriction_kind: "exclude"
    )
    assert_equal "Category", restriction.restriction_type
  end

  test "scope include returns only include type restrictions" do
    product = products(:ruby_guide)
    restriction1 = CouponRestriction.create!(
      coupon: @coupon,
      restriction: product,
      restriction_kind: "include"
    )
    restriction2 = CouponRestriction.create!(
      coupon: @coupon,
      restriction: product,
      restriction_kind: "exclude"
    )

    assert_includes CouponRestriction.include, restriction1
    assert_not_includes CouponRestriction.include, restriction2
  end

  test "scope exclude returns only exclude type restrictions" do
    product = products(:ruby_guide)
    restriction1 = CouponRestriction.create!(
      coupon: @coupon,
      restriction: product,
      restriction_kind: "include"
    )
    restriction2 = CouponRestriction.create!(
      coupon: @coupon,
      restriction: product,
      restriction_kind: "exclude"
    )

    assert_not_includes CouponRestriction.exclude, restriction1
    assert_includes CouponRestriction.exclude, restriction2
  end

  test "scope products returns only product restrictions" do
    product = products(:ruby_guide)
    category = categories(:programming_ebook)
    product_restriction = CouponRestriction.create!(
      coupon: @coupon,
      restriction: product,
      restriction_type: "Product",
      restriction_kind: "include"
    )
    category_restriction = CouponRestriction.create!(
      coupon: @coupon,
      restriction: category,
      restriction_type: "Category",
      restriction_kind: "include"
    )

    assert_includes CouponRestriction.products, product_restriction
    assert_not_includes CouponRestriction.products, category_restriction
  end

  test "scope categories returns only category restrictions" do
    product = products(:ruby_guide)
    category = categories(:programming_ebook)
    product_restriction = CouponRestriction.create!(
      coupon: @coupon,
      restriction: product,
      restriction_type: "Product",
      restriction_kind: "include"
    )
    category_restriction = CouponRestriction.create!(
      coupon: @coupon,
      restriction: category,
      restriction_type: "Category",
      restriction_kind: "include"
    )

    assert_not_includes CouponRestriction.categories, product_restriction
    assert_includes CouponRestriction.categories, category_restriction
  end

  test "belongs to coupon" do
    assert_respond_to @coupon, :coupon_restrictions
  end

  test "belongs to restriction polymorphic" do
    product = products(:ruby_guide)
    restriction = CouponRestriction.new(
      coupon: @coupon,
      restriction: product,
      restriction_kind: "include"
    )

    assert_respond_to restriction, :restriction
  end
end
