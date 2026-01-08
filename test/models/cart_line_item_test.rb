require "test_helper"

class CartLineItemTest < ActiveSupport::TestCase
  setup do
    @line_item = cart_line_items(:ruby_guide_in_cart)
  end

  test "should be valid with valid attributes" do
    assert @line_item.valid?
  end

  test "should belong to cart" do
    assert_respond_to @line_item, :cart
  end

  test "should belong to cartable" do
    assert_respond_to @line_item, :cartable
  end

  test "should return price when minimum_price is set" do
    @line_item.cartable.update(minimum_price: 50000)
    @line_item.update(price: 70000)

    assert_equal 70000, @line_item.price
  end

  test "should return actual_price when minimum_price is not set" do
    product = @line_item.cartable
    product.update(minimum_price: nil, price: 150000)
    product.reload

    assert_equal 99000, @line_item.price
  end

  test "should return sale_price when on sale and no minimum_price" do
    assert_equal 99000, @line_item.price
  end

  test "should allow different line_items for different carts" do
    assert_equal carts(:user_one_cart), @line_item.cart
    assert_equal carts(:user_two_cart), cart_line_items(:business_course_in_cart).cart
  end

  test "should allow multiple products in same cart" do
    assert_equal 2, carts(:user_one_cart).line_items.count
  end
end
