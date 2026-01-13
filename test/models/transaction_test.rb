require "test_helper"

class TransactionTest < ActiveSupport::TestCase
  setup do
    Current.settings = { "payment_provider" => "midtrans" }
    @cart = carts(:guest_cart)
    @product = products(:design_collection)
    @cart.line_items.create(cartable: @product, price: 299000)
    @transaction = Transaction.new(@cart)
  end

  test "should initialize with cart" do
    assert_equal @cart, @transaction.cart
  end

  test "should create order from cart" do
    order = @transaction.create(
      customer_name: "Test User",
      customer_email_address: "test@example.com",
      customer_agree_to_terms: true
    )

    assert order.persisted?
    assert_equal @cart, order.cart
    assert_equal 299000, order.total_price
    assert_equal "Test User", order.customer_name
  end

  test "should create order with line items from cart" do
    order = @transaction.create(
      customer_name: "Test User",
      customer_email_address: "test@example.com",
      customer_agree_to_terms: true
    )

    assert_equal 1, order.line_items.count
    assert_equal @product, order.line_items.first.orderable
    assert_equal @product.name, order.line_items.first.orderable_name
    assert_equal 299000, order.line_items.first.orderable_price
  end

  test "should create order with multiple line items from cart" do
    product2 = products(:ruby_guide)
    @cart.line_items.create(cartable: product2, price: 99000)

    order = @transaction.create(
      customer_name: "Test User",
      customer_email_address: "test@example.com",
      customer_agree_to_terms: true
    )

    assert_equal 2, order.line_items.count
  end

  test "should clear cart line items after creating order" do
    assert_difference("@cart.line_items.count", -1) do
      @transaction.create(
        customer_name: "Test User",
        customer_email_address: "test@example.com",
        customer_agree_to_terms: true
      )
    end
  end

  test "should return invalid order if params are invalid" do
    order = @transaction.create(
      customer_name: "Test User",
      customer_email_address: "test@example.com",
      customer_agree_to_terms: false
    )

    assert order.invalid?
  end

  test "should not clear cart line items if order is invalid" do
    initial_count = @cart.line_items.count
    @transaction.create(
      customer_name: "Test User",
      customer_email_address: "test@example.com",
      customer_agree_to_terms: false
    )

    assert_equal initial_count, @cart.line_items.count
  end

  test "should create order with physical products from cart" do
    cart = carts(:user_one_cart)
    transaction = Transaction.new(cart)

    order = transaction.create(
      customer_name: "Test User",
      customer_email_address: "test@example.com",
      customer_phone: "08123456789",
      address_line: "123 Test Street",
      shipping_province_id: provinces(:jawa_barat).id,
      shipping_city_id: cities(:jakarta_selatan).id,
      shipping_district_id: districts(:tebet).id,
      shipping_subdistrict_id: subdistricts(:gedong_pancoran).id,
      shipping_cost_id: shipping_costs(:jne_district_yes).id,
      customer_agree_to_terms: true
    )

    assert order.persisted?
    assert_equal true, order.has_physical_products
  end

  test "should create order with has_physical_products flag based on cart contents" do
    cart = carts(:guest_cart)
    digital_product = products(:ruby_guide)
    cart.line_items.create(cartable: digital_product, price: 99000)
    transaction = Transaction.new(cart)

    order = transaction.create(
      customer_name: "Test User",
      customer_email_address: "test@example.com",
      customer_agree_to_terms: true
    )

    assert_equal false, order.has_physical_products
  end

  test "should capture weight from physical product cart line items" do
    cart = carts(:user_one_cart)
    transaction = Transaction.new(cart)

    order = transaction.create(
      customer_name: "Test User",
      customer_email_address: "test@example.com",
      customer_phone: "08123456789",
      address_line: "123 Test Street",
      shipping_province_id: provinces(:jawa_barat).id,
      shipping_city_id: cities(:jakarta_selatan).id,
      shipping_district_id: districts(:tebet).id,
      shipping_subdistrict_id: subdistricts(:gedong_pancoran).id,
      shipping_cost_id: shipping_costs(:jne_district_yes).id,
      customer_agree_to_terms: true
    )

    physical_line_items = order.line_items.select(&:physical_product?)
    assert physical_line_items.any?
    physical_line_items.each do |item|
      assert_not_nil item.weight
      assert item.weight.positive?
    end
  end
end
