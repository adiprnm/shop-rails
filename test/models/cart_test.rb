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
    product = products(:premium_t_shirt)
    variant = product_variants(:t_shirt_red_small)
    line_item = @cart.add_item(product, 150000, variant)
    assert @cart.line_items.include?(line_item)
    assert_equal variant, line_item.product_variant
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
end
