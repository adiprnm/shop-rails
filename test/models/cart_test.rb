require "test_helper"

class CartTest < ActiveSupport::TestCase
  setup do
    @cart = carts(:user_one_cart)
  end

  test "should be valid with valid attributes" do
    assert @cart.valid?
  end

  test "should have many line_items" do
    assert_respond_to @cart, :line_items
  end

  test "should have many orders" do
    assert_respond_to @cart, :orders
  end

  test "should add item to cart" do
    product = products(:business_audio_course)
    line_item = @cart.add_item(product, 10000)
    assert @cart.line_items.include?(line_item)
    assert_equal 10000, line_item.price
  end

  test "should update existing line item when adding same product" do
    product = products(:ruby_guide)
    @cart.line_items.delete_all
    @cart.add_item(product, 10000)
    line_item = @cart.add_item(product, 15000)
    assert_equal 15000, line_item.price
    assert_equal 1, @cart.line_items.count
  end

  test "should remove item from cart" do
    line_item = @cart.line_items.first
    @cart.remove_item(line_item.id)
    assert_equal 2, @cart.line_items.count
  end

  test "should calculate total_price correctly" do
    assert_equal 548000, @cart.total_price
  end

  test "should return 0 for empty cart" do
    @cart.line_items.delete_all
    assert_equal 0, @cart.total_price
  end

  test "should delete line_items when cart is destroyed" do
    cart = Cart.create!(session_id: SecureRandom.uuid)
    line_item = cart.line_items.create(cartable: products(:design_collection), price: 10000)

    assert_difference("CartLineItem.count", -1) do
      cart.destroy
    end
  end

  test "should add physical product with variant to cart" do
    @cart.line_items.delete_all
    product = products(:premium_t_shirt)
    variant = product_variants(:t_shirt_red_small)
    line_item = @cart.add_item(product, 150000, variant)
    assert @cart.line_items.include?(line_item)
    assert_equal variant, line_item.product_variant
    assert_equal 1, line_item.quantity
  end

  test "should add physical product with variant and custom quantity" do
    @cart.line_items.delete_all
    product = products(:premium_t_shirt)
    variant = product_variants(:t_shirt_red_small)
    line_item = @cart.add_item(product, 150000, variant, 5)
    assert @cart.line_items.include?(line_item)
    assert_equal 5, line_item.quantity
  end

  test "should accumulate quantity for physical product with same variant" do
    @cart.line_items.delete_all
    product = products(:premium_t_shirt)
    variant = product_variants(:t_shirt_red_small)

    first_item = @cart.add_item(product, 150000, variant, 2)
    assert_equal 2, first_item.quantity

    @cart.reload

    second_item = @cart.add_item(product, 150000, variant, 3)
    assert_equal 5, second_item.quantity

    @cart.reload

    assert_equal 1, @cart.line_items.count
    assert_equal 5, @cart.line_items.first.quantity
  end

  test "should default to quantity 1 when not specified" do
    @cart.line_items.delete_all
    product = products(:premium_t_shirt)
    variant = product_variants(:t_shirt_red_small)
    line_item = @cart.add_item(product, 150000, variant)

    assert_equal 1, line_item.quantity
  end

  test "should not affect digital product with quantity parameter" do
    product = products(:ruby_guide)
    line_item = @cart.add_item(product, 10000, nil, 5)

    assert @cart.line_items.include?(line_item)
    assert_equal 1, line_item.quantity
  end

  test "should raise error when adding physical product without variant" do
    product = products(:premium_t_shirt)
    assert_raises(ArgumentError, "Variant must be specified for physical products") do
      @cart.add_item(product, 150000)
    end
  end

  test "should raise error when adding physical product with inactive variant" do
    product = products(:premium_t_shirt)
    variant = product_variants(:t_shirt_discontinued)
    assert_raises(ArgumentError, "Selected variant is not available") do
      @cart.add_item(product, 150000, variant)
    end
  end

  test "should raise error when adding physical product with variant from different product" do
    product = products(:premium_t_shirt)
    variant = product_variants(:ebook_black)
    assert_raises(ArgumentError, "Variant does not belong to this product") do
      @cart.add_item(product, 150000, variant)
    end
  end

  test "should raise error when adding physical product with out of stock variant" do
    product = products(:premium_t_shirt)
    variant = product_variants(:t_shirt_green_large)
    assert_raises(ArgumentError, "Selected variant is out of stock") do
      @cart.add_item(product, 150000, variant)
    end
  end

  test "should return digital_items" do
    assert_equal 2, @cart.digital_items.count
    assert @cart.digital_items.all? { |item| !item.physical_product? }
  end

  test "should return physical_items" do
    assert_equal 1, @cart.physical_items.count
    assert @cart.physical_items.all?(&:physical_product?)
  end

  test "should calculate digital_items_total" do
    assert_equal 398000, @cart.digital_items_total
  end

  test "should calculate physical_items_total" do
    assert_equal 150000, @cart.physical_items_total
  end

  test "should return true from contains_physical_product? when cart has physical items" do
    assert @cart.contains_physical_product?
  end

  test "should return false from contains_physical_product? when cart has no physical items" do
    cart = carts(:guest_cart)
    assert_not cart.contains_physical_product?
  end

  test "should return 0 discount_amount when no coupon" do
    assert_equal 0, @cart.discount_amount
  end

  test "should return coupon discount when coupon applied" do
    coupon = Coupon.create!(
      code: "TEST10",
      discount_type: "percent_cart",
      discount_amount: 10,
      state: "active"
    )
    @cart.coupon_code = coupon.code
    @cart.stubs(:subtotal_price).returns(100_000)

    assert_equal 10_000, @cart.discount_amount
  end

  test "total_price should subtract discount from subtotal" do
    coupon = Coupon.create!(
      code: "TEST10",
      discount_type: "fixed_cart",
      discount_amount: 5000,
      state: "active"
    )
    @cart.coupon_code = coupon.code
    @cart.stubs(:subtotal_price).returns(100_000)
    coupon.stubs(:calculate_discount).with(@cart).returns(5000)

    assert_equal 95_000, @cart.total_price
  end

  test "total_price should never go below zero" do
    @cart.stubs(:subtotal_price).returns(5_000)
    @cart.stubs(:discount_amount).returns(10_000)

    assert_equal 0, @cart.total_price
  end

  test "apply_coupon! should return false for invalid code" do
    assert_not @cart.apply_coupon!("INVALID_CODE")
    assert_includes @cart.errors[:coupon_code].to_s, "is invalid"
  end

  test "apply_coupon! should return true and set coupon_code for valid coupon" do
    coupon = Coupon.create!(
      code: "VALID10",
      discount_type: "percent_cart",
      discount_amount: 10,
      state: "active"
    )

    assert @cart.apply_coupon!(coupon.code)
    assert_equal coupon.code, @cart.coupon_code
  end

  test "apply_coupon! should validate coupon against cart" do
    coupon = Coupon.create!(
      code: "TEST",
      discount_type: "percent_cart",
      discount_amount: 10,
      state: "active",
      minimum_amount: 1_000_000
    )
    @cart.stubs(:subtotal_price).returns(100_000)

    assert_not @cart.apply_coupon!(coupon.code)
    assert_includes @cart.errors[:coupon_code].to_s, "is invalid"
  end

  test "remove_coupon! should clear coupon_code" do
    @cart.coupon_code = "TEST"
    assert @cart.remove_coupon!
    assert_nil @cart.coupon_code
  end

  test "should calculate subtotal_price correctly" do
    expected = @cart.line_items.sum(&:price)
    assert_equal expected, @cart.subtotal_price
  end
end
