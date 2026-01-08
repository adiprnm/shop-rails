require "test_helper"

class CartsControllerTest < ActionDispatch::IntegrationTest
  setup do
    @cart = carts(:user_one_cart)
    Current.cart = @cart
  end

  test "should show cart" do
    get cart_path
    assert_response :success
  end

  test "should assign order when order_id is present" do
    order = orders(:paid_order)

    get cart_path(order_id: order.order_id)
    assert_response :success
    assert_equal assigns(:payable).class, Order
  end

  test "should assign donation when donation_id is present" do
    donation = donations(:named_donation)

    get cart_path(order_id: donation.donation_id)
    assert_response :success
    assert_equal assigns(:payable).class, Donation
  end

  test "should initialize order if order_id not found" do
    get cart_path(order_id: "non-existent-id")
    assert_response :success
    assert assigns(:payable).new_record?
  end

  test "should not assign payable when no order_id" do
    get cart_path
    assert_response :success
    assert_nil assigns(:payable)
  end
end
