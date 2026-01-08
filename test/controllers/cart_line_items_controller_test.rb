require "test_helper"

class CartLineItemsControllerTest < ActionDispatch::IntegrationTest
  setup do
    @cart = carts(:user_one_cart)
    @line_item = cart_line_items(:ruby_guide_in_cart)
  end

  test "should destroy line item" do
    Cart.stubs(:find_or_create_by).returns(@cart)
    assert_difference("CartLineItem.count", -1) do
      delete cart_line_item_path(@line_item.id)
    end

    assert_redirected_to cart_path
  end

  test "should only destroy line item from current cart" do
    Cart.stubs(:find_or_create_by).returns(@cart)
    other_cart = carts(:user_two_cart)
    other_line_item = cart_line_items(:business_course_in_cart)

    assert_no_difference("other_cart.line_items.count") do
      delete cart_line_item_path(@line_item.id)
    end

    assert_redirected_to cart_path
  end

  test "should redirect to cart after destroying line item" do
    Cart.stubs(:find_or_create_by).returns(@cart)
    delete cart_line_item_path(@line_item.id)
    assert_redirected_to cart_path
  end
end
