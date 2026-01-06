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
    assert_equal 1, @cart.line_items.count
  end

  test "should calculate total_price correctly" do
    assert_equal 398000, @cart.total_price
  end

  test "should return 0 for empty cart" do
    @cart.line_items.delete_all
    assert_equal 0, @cart.total_price
  end

  test "should delete line_items when cart is destroyed" do
    cart = carts(:guest_cart)
    line_item = cart.line_items.create(cartable: products(:design_collection), price: 10000)

    assert_difference("CartLineItem.count", -1) do
      cart.destroy
    end
  end
end
