require "test_helper"

class CouponTest < ActiveSupport::TestCase
  setup do
    @coupon = Coupon.new(
      code: "TEST10",
      discount_type: "percent_cart",
      discount_amount: 10,
      state: "active"
    )
    @cart = carts(:guest_cart)
  end

  test "valid with required attributes" do
    assert @coupon.valid?
  end

  test "requires unique code (case insensitive)" do
    @coupon.save!
    duplicate = Coupon.new(code: @coupon.code.upcase, discount_type: "fixed_cart", discount_amount: 1000)
    assert_not duplicate.valid?
    assert_includes duplicate.errors[:code], "has already been taken"
  end

  test "requires discount_amount for non-free_shipping types" do
    @coupon.discount_amount = nil
    @coupon.discount_type = "fixed_cart"
    assert_not @coupon.valid?
    assert_includes @coupon.errors[:discount_amount], "can't be blank"
  end

  test "does not require discount_amount for free_shipping" do
    @coupon.discount_type = "free_shipping"
    @coupon.discount_amount = nil
    assert @coupon.valid?
  end

  test "valid_now? returns true for active coupon without date restrictions" do
    @coupon.starts_at = nil
    @coupon.expires_at = nil
    @coupon.state = "active"
    assert @coupon.valid_now?
  end

  test "valid_now? returns false for inactive coupon" do
    @coupon.state = "inactive"
    assert_not @coupon.valid_now?
  end

  test "valid_now? returns false for expired coupon" do
    @coupon.expires_at = 1.day.ago
    @coupon.state = "active"
    assert_not @coupon.valid_now?
  end

  test "valid_now? returns false for coupon that hasn't started" do
    @coupon.starts_at = 1.day.from_now
    @coupon.state = "active"
    assert_not @coupon.valid_now?
  end

  test "usage_limit_reached returns true when limit reached" do
    @coupon.usage_limit = 1
    @coupon.usage_count = 1
    assert @coupon.send(:usage_limit_reached?)
  end

  test "usage_limit_reached returns false when under limit" do
    @coupon.usage_limit = 10
    @coupon.usage_count = 5
    assert_not @coupon.send(:usage_limit_reached?)
  end

  test "usage_limit_reached returns false when no limit" do
    @coupon.usage_limit = nil
    @coupon.usage_count = 5
    assert_not @coupon.send(:usage_limit_reached?)
  end

  test "meets_minimum_amount returns true when above minimum" do
    @coupon.minimum_amount = 50_000
    assert @coupon.send(:meets_minimum_amount?, 100_000)
  end

  test "meets_minimum_amount returns false when below minimum" do
    @coupon.minimum_amount = 100_000
    assert_not @coupon.send(:meets_minimum_amount?, 50_000)
  end

  test "meets_maximum_amount returns true when below maximum" do
    @coupon.maximum_amount = 200_000
    assert @coupon.send(:meets_maximum_amount?, 100_000)
  end

  test "meets_maximum_amount returns false when above maximum" do
    @coupon.maximum_amount = 100_000
    assert_not @coupon.send(:meets_maximum_amount?, 200_000)
  end

  test "meets_maximum_amount returns true when no maximum" do
    @coupon.maximum_amount = nil
    assert @coupon.send(:meets_maximum_amount?, 1_000_000)
  end

  test "calculate_discount for percent_cart" do
    @coupon.discount_type = "percent_cart"
    @coupon.discount_amount = 10
    @cart.stubs(:subtotal_price).returns(100_000)
    assert_equal 10_000, @coupon.calculate_discount(@cart)
  end

  test "calculate_discount for fixed_cart" do
    @coupon.discount_type = "fixed_cart"
    @coupon.discount_amount = 5000
    @cart.stubs(:subtotal_price).returns(100_000)
    assert_equal 5000, @coupon.calculate_discount(@cart)
  end

  test "calculate_discount caps discount at subtotal for fixed_cart" do
    @coupon.discount_type = "fixed_cart"
    @coupon.discount_amount = 200_000
    @cart.stubs(:subtotal_price).returns(100_000)
    assert_equal 100_000, @coupon.calculate_discount(@cart)
  end

  test "calculate_discount for free_shipping" do
    @coupon.discount_type = "free_shipping"
    assert_equal 0, @coupon.calculate_discount(@cart)
  end

  test "calculate_discount returns 0 for invalid coupon" do
    @coupon.state = "expired"
    @cart.stubs(:subtotal_price).returns(100_000)
    assert_equal 0, @coupon.calculate_discount(@cart)
  end

  test "enum discount_type has correct values" do
    assert_equal "fixed_cart", Coupon.discount_types.keys[0]
    assert_equal "percent_cart", Coupon.discount_types.keys[1]
    assert_equal "fixed_product", Coupon.discount_types.keys[2]
    assert_equal "percent_product", Coupon.discount_types.keys[3]
    assert_equal "free_shipping", Coupon.discount_types.keys[4]
  end

  test "enum state has correct values" do
    assert_equal "active", Coupon.states.keys[0]
    assert_equal "inactive", Coupon.states.keys[1]
    assert_equal "expired", Coupon.states.keys[2]
  end

  test "meets_product_restrictions returns true when no restrictions" do
    @coupon.stubs(:included_products).returns([])
    @coupon.stubs(:excluded_products).returns([])

    assert @coupon.send(:meets_product_restrictions?, @cart)
  end

  test "meets_product_restrictions returns false when product excluded" do
    product = products(:ruby_guide)
    @coupon.stubs(:excluded_products).returns([ product ])

    cart_item = mock("cart_item")
    cart_item.stubs(:cartable).returns(product)
    cart_item.stubs(:cartable_id).returns(product.id)
    @cart.stubs(:line_items).returns([ cart_item ])

    assert_not @coupon.send(:meets_product_restrictions?, @cart)
  end

  test "meets_product_restrictions returns false when product not included" do
    product1 = products(:ruby_guide)
    product2 = products(:design_collection)

    @coupon.stubs(:included_products).returns([ product1 ])
    @coupon.stubs(:excluded_products).returns([])

    cart_item = mock("cart_item")
    cart_item.stubs(:cartable).returns(product2)
    cart_item.stubs(:cartable_id).returns(product2.id)
    @cart.stubs(:line_items).returns([ cart_item ])

    assert_not @coupon.send(:meets_product_restrictions?, @cart)
  end

  test "meets_product_restrictions returns true when product included" do
    product = products(:ruby_guide)

    @coupon.stubs(:included_products).returns([ product ])
    @coupon.stubs(:excluded_products).returns([])

    cart_item = mock("cart_item")
    cart_item.stubs(:cartable_id).returns(product.id)
    cart_item.stubs(:cartable).returns(product)
    @cart.stubs(:line_items).returns([ cart_item ])

    assert @coupon.send(:meets_product_restrictions?, @cart)
  end

  test "product_eligible returns true when no restrictions" do
    @coupon.stubs(:included_products).returns([])
    @coupon.stubs(:excluded_products).returns([])

    product = products(:ruby_guide)
    assert @coupon.send(:product_eligible?, product)
  end

  test "product_eligible returns false when product excluded" do
    product = products(:ruby_guide)
    @coupon.stubs(:excluded_products).returns([ product ])
    @coupon.stubs(:included_products).returns([])

    assert_not @coupon.send(:product_eligible?, product)
  end

  test "product_eligible returns true when product included" do
    product = products(:ruby_guide)
    @coupon.stubs(:excluded_products).returns([])
    @coupon.stubs(:included_products).returns([ product ])

    assert @coupon.send(:product_eligible?, product)
  end

  test "calculate_fixed_product_discount excludes sale items when exclude_sale_items is true" do
    @coupon.discount_type = "fixed_product"
    @coupon.discount_amount = 5000
    @coupon.exclude_sale_items = true

    sale_product = products(:ruby_guide)
    sale_product.stubs(:sale_price?).returns(true)

    normal_product = products(:design_collection)
    normal_product.stubs(:sale_price?).returns(false)

    sale_item = mock("cart_item")
    sale_item.stubs(:cartable).returns(sale_product)
    sale_item.stubs(:price).returns(100_000)

    normal_item = mock("cart_item")
    normal_item.stubs(:cartable).returns(normal_product)
    normal_item.stubs(:price).returns(100_000)

    @cart.stubs(:line_items).returns([ sale_item, normal_item ])

    discount = @coupon.send(:calculate_fixed_product_discount, @cart)

    assert_equal 100_000, discount  # Only normal product, not sale product
  end

  test "calculate_percent_product_discount excludes sale items when exclude_sale_items is true" do
    @coupon.discount_type = "percent_product"
    @coupon.discount_amount = 10  # 10%
    @coupon.exclude_sale_items = true

    sale_product = products(:ruby_guide)
    sale_product.stubs(:sale_price?).returns(true)

    normal_product = products(:design_collection)
    normal_product.stubs(:sale_price?).returns(false)

    sale_item = mock("cart_item")
    sale_item.stubs(:cartable).returns(sale_product)
    sale_item.stubs(:price).returns(100_000)

    normal_item = mock("cart_item")
    normal_item.stubs(:cartable).returns(normal_product)
    normal_item.stubs(:price).returns(100_000)

    @cart.stubs(:line_items).returns([ sale_item, normal_item ])

    discount = @coupon.send(:calculate_percent_product_discount, @cart)

    assert_equal 10_000, discount  # 10% of 100,000, not 10% of 200,000
  end

  test "meets_category_restrictions returns true when no restrictions" do
    @coupon.stubs(:included_categories).returns([])
    @coupon.stubs(:excluded_categories).returns([])

    assert @coupon.send(:meets_category_restrictions?, @cart)
  end

  test "meets_category_restrictions returns false when category excluded" do
    category = categories(:programming_ebook)
    product = products(:ruby_guide)
    product.categories << category

    @coupon.stubs(:excluded_categories).returns([ category ])

    cart_item = mock("cart_item")
    cart_item.stubs(:cartable).returns(product)

    @cart.stubs(:line_items).returns([ cart_item ])

    assert_not @coupon.send(:meets_category_restrictions?, @cart)
  end

  test "meets_category_restrictions returns false when product not in included categories" do
    category1 = categories(:programming_ebook)
    category2 = categories(:design_template)
    product1 = products(:ruby_guide)
    product1.categories << category1
    product2 = products(:design_collection)
    product2.categories << category2

    @coupon.stubs(:included_categories).returns([ category1 ])
    @coupon.stubs(:excluded_categories).returns([])

    cart_item = mock("cart_item")
    cart_item.stubs(:cartable).returns(product2)

    @cart.stubs(:line_items).returns([ cart_item ])

    assert_not @coupon.send(:meets_category_restrictions?, @cart)
  end

  test "meets_category_restrictions returns true when product in included categories" do
    category = categories(:programming_ebook)
    product = products(:ruby_guide)
    product.categories << category

    @coupon.stubs(:included_categories).returns([ category ])
    @coupon.stubs(:excluded_categories).returns([])

    cart_item = mock("cart_item")
    cart_item.stubs(:cartable).returns(product)

    @cart.stubs(:line_items).returns([ cart_item ])

    assert @coupon.send(:meets_category_restrictions?, @cart)
  end

  test "exclude_sale_items option works with category restrictions" do
    @coupon.discount_type = "percent_cart"
    @coupon.discount_amount = 10
    @coupon.exclude_sale_items = true

    category = categories(:programming_ebook)
    sale_product = products(:ruby_guide)
    sale_product.categories << category
    sale_product.stubs(:sale_price?).returns(true)

    normal_product = products(:design_collection)
    normal_product.categories << category
    normal_product.stubs(:sale_price?).returns(false)

    @cart.stubs(:subtotal_price).returns(100_000)
    @coupon.stubs(:included_categories).returns([ category ])
    @coupon.stubs(:excluded_categories).returns([])

    # Category restrictions return true (both products have the category)
    @coupon.stubs(:meets_category_restrictions?).returns(true)

    discount = @coupon.calculate_discount(@cart)

    # 10% discount of 100,000 = 10,000
    assert_equal 10_000, discount
  end
end
