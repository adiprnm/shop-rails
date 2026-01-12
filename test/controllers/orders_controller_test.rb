require "test_helper"

class OrdersControllerTest < ActionDispatch::IntegrationTest
  setup do
    @cart = carts(:guest_cart)
    @product = products(:design_collection)
    @default_headers = { headers: { "CF-Connecting-IP" => "10.0.0.1" } }
    @jne_yes = shipping_costs(:jne_yes)
  end

  test "should create order successfully" do
    result = @cart.line_items.create(cartable: @product, price: 99000)

    assert_difference("Order.count") do
      post orders_path,
        params: {
          customer_name: "Test User",
          customer_email_address: "test@example.com",
          customer_agree_to_terms: "1"
        },
        **@default_headers

      assert_redirected_to order_path(Order.last.order_id), "Should redirect to order page but got #{response.redirect_url} with flash: #{flash[:alert]}"
    end
  end

  test "should redirect to payment gateway when total_price > 0" do
    @cart.line_items.create(cartable: @product, price: 99000)
    Setting.payment_provider.update value: "midtrans"
    Transaction::Payment::Midtrans.any_instance.stubs(:redirect_url).returns("https://app.sandbox.midtrans.com/testing")

    post orders_path, params: {
        customer_name: "Test User",
        customer_email_address: "test@example.com",
        customer_agree_to_terms: "1"
      },
      **@default_headers

    assert_redirected_to %r{^https://app.sandbox.midtrans.com/}
  end

  test "should mark order as paid when total_price is zero" do
    @cart.line_items.create(cartable: @product, price: 0)

    assert_difference("Order.paid.count") do
      post orders_path, params: {
        customer_name: "Test User",
        customer_email_address: "test@example.com",
        customer_agree_to_terms: "1"
      },
      **@default_headers
    end

    assert_redirected_to cart_path
    assert_equal "paid", Order.last.state
  end

  test "should not create order with missing customer_name" do
    @cart.line_items.create(cartable: @product, price: 99000)

    assert_no_difference("Order.count") do
      post orders_path, params: {
        customer_email_address: "test@example.com",
        customer_agree_to_terms: "1"
      },
      **@default_headers
    end

    assert_redirected_to cart_path
    assert_not_nil flash[:alert]
  end

  test "should not create order without agreeing to terms" do
    @cart.line_items.create(cartable: @product, price: 99000)

    assert_no_difference("Order.count") do
      post orders_path, params: {
        customer_name: "Test User",
        customer_email_address: "test@example.com",
        customer_agree_to_terms: "0"
      },
      **@default_headers
    end

    assert_redirected_to cart_path
    assert_not_nil flash[:alert]
  end

  test "should clear cart after creating order" do
    line_item = @cart.line_items.create(cartable: @product, price: 99000)

    assert_difference("@cart.line_items.count", -1) do
      post orders_path, params: {
        customer_name: "Test User",
        customer_email_address: "test@example.com",
        customer_agree_to_terms: "1"
      },
      **@default_headers
    end
  end

  test "should show order" do
    get order_path(orders(:paid_order).order_id)
    assert_response :success
  end

  test "should mark order as expired if past expiry time" do
    order = orders(:expired_order)
    get order_path(order.order_id)
    assert_response :success
    assert order.reload.expired?
  end

  test "should not modify state if not expired" do
    get order_path(orders(:pending_order).order_id)
    assert_response :success
    assert orders(:pending_order).pending?
  end

  test "should create order with newsletter subscription" do
    @cart.line_items.create(cartable: @product, price: 99000)

    post orders_path, params: {
      customer_name: "Test User",
      customer_email_address: "test@example.com",
      customer_agree_to_terms: "1",
      customer_agree_to_receive_newsletter: "1"
    },
    **@default_headers

    assert Order.last.customer_agree_to_receive_newsletter
  end

  test "should create order without newsletter subscription" do
    @cart.line_items.create(cartable: @product, price: 99000)

    post orders_path, params: {
      customer_name: "Test User",
      customer_email_address: "test@example.com",
      customer_agree_to_terms: "1"
    },
    **@default_headers

    assert_not Order.last.customer_agree_to_receive_newsletter
  end

  test "should create order with valid shipping_cost_id for physical product" do
    physical_product = products(:premium_t_shirt)
    @cart.line_items.create(cartable: physical_product, price: 50000)

    assert_difference("Order.count") do
      post orders_path, params: {
        customer_name: "Test User",
        customer_email_address: "test@example.com",
        customer_phone: "08123456789",
        customer_agree_to_terms: "1",
        address_line: "Test Address 123",
        shipping_province_id: @jne_yes.origin.id,
        shipping_city_id: @jne_yes.destination.id,
        shipping_district_id: 1,
        shipping_subdistrict_id: 1,
        shipping_cost_id: @jne_yes.id
      },
      **@default_headers

      assert_redirected_to order_path(Order.last.order_id), "Got redirected to #{response.redirect_url} with flash: #{flash[:alert]}"
    end
  end

  test "should not create order with invalid shipping_cost_id" do
    physical_product = products(:premium_t_shirt)
    @cart.line_items.create(cartable: physical_product, price: 50000)

    assert_no_difference("Order.count") do
      post orders_path, params: {
        customer_name: "Test User",
        customer_email_address: "test@example.com",
        customer_phone: "08123456789",
        customer_agree_to_terms: "1",
        address_line: "Test Address 123",
        shipping_province_id: 1,
        shipping_city_id: 1,
        shipping_cost_id: 999999
      },
      **@default_headers

      assert_redirected_to cart_path
      assert_not_nil flash[:alert]
    end
  end

  test "should not create order for physical product without shipping_cost_id" do
    physical_product = products(:premium_t_shirt)
    @cart.line_items.create(cartable: physical_product, price: 50000)

    assert_no_difference("Order.count") do
      post orders_path, params: {
        customer_name: "Test User",
        customer_email_address: "test@example.com",
        customer_phone: "08123456789",
        customer_agree_to_terms: "1",
        address_line: "Test Address 123",
        shipping_province_id: 1,
        shipping_city_id: 1
      },
      **@default_headers

      assert_redirected_to cart_path
      assert_not_nil flash[:alert]
    end
  end

  test "should not allow shipping cost manipulation via shipping_cost_id" do
    physical_product = products(:premium_t_shirt)
    @cart.line_items.create(cartable: physical_product, price: 50000)

    post orders_path, params: {
      customer_name: "Test User",
      customer_email_address: "test@example.com",
      customer_phone: "08123456789",
      customer_agree_to_terms: "1",
      address_line: "Test Address 123",
      shipping_province_id: @jne_yes.origin.id,
      shipping_city_id: @jne_yes.destination.id,
      shipping_district_id: 1,
      shipping_subdistrict_id: 1,
      shipping_cost_id: @jne_yes.id
    },
    **@default_headers

    assert_redirected_to order_path(Order.last.order_id)
    assert_equal 10000, Order.last.shipping_cost
    assert_equal "jne", Order.last.shipping_provider
    assert_equal "YES", Order.last.shipping_method
    assert_equal 50000 + 10000, Order.last.total_price
  end
end
