require "test_helper"

class Admin::OrdersControllerTest < ActionDispatch::IntegrationTest
  setup do
    @order = orders(:pending_order)
    @admin_auth = ActionController::HttpAuthentication::Basic.encode_credentials("admin", "admin123")
  end

  test "should get index" do
    get admin_orders_path, headers: { "HTTP_AUTHORIZATION" => @admin_auth }
    assert_response :success
  end

  test "should paginate orders" do
    get admin_orders_path, headers: { "HTTP_AUTHORIZATION" => @admin_auth }
    assert_response :success
    assert_not_nil assigns(:pagination)
  end

  test "should filter orders by product_id" do
    product = products(:ruby_guide)

    get admin_orders_path(product_id: product.id), headers: { "HTTP_AUTHORIZATION" => @admin_auth }
    assert_response :success
  end

  test "should filter orders by state" do
    @order.update(state: "paid")

    get admin_orders_path(state: "paid"), headers: { "HTTP_AUTHORIZATION" => @admin_auth }
    assert_response :success
  end

  test "should paginate with custom page" do
    get admin_orders_path(page: 2), headers: { "HTTP_AUTHORIZATION" => @admin_auth }
    assert_response :success
  end

  test "should show order" do
    get admin_order_path(@order), headers: { "HTTP_AUTHORIZATION" => @admin_auth }
    assert_response :success
  end

  test "should get edit" do
    get edit_admin_order_path(@order), headers: { "HTTP_AUTHORIZATION" => @admin_auth }
    assert_response :success
  end

  test "should update order" do
    patch admin_order_path(@order), params: {
      order: {
        customer_name: "Updated Name",
        customer_email_address: "updated@example.com"
      }
    }, headers: { "HTTP_AUTHORIZATION" => @admin_auth }

    assert_redirected_to admin_order_path(@order)
    assert_equal "Updated Name", @order.reload.customer_name
  end

  test "should update order state" do
    patch admin_order_path(@order), params: {
      order: { state: "paid" }
    }, headers: { "HTTP_AUTHORIZATION" => @admin_auth }

    assert_redirected_to admin_order_path(@order)
    assert_equal "paid", @order.reload.state
  end

  test "should mark evidences as checked when state changes" do
    evidence = @order.payment_evidences.create(file: fixture_file_upload("test.pdf", "application/pdf"), checked: false)

    patch admin_order_path(@order), params: {
      order: { state: "paid" }
    }, headers: { "HTTP_AUTHORIZATION" => @admin_auth }

    assert evidence.reload.checked?
  end

  test "should not mark evidences as checked when state does not change" do
    evidence = @order.payment_evidences.create(file: fixture_file_upload("test.pdf", "application/pdf"), checked: false)

    patch admin_order_path(@order), params: {
      order: { customer_name: "Updated Name" }
    }, headers: { "HTTP_AUTHORIZATION" => @admin_auth }

    assert_not evidence.reload.checked?
  end

  test "should update order remark" do
    patch admin_order_path(@order), params: {
      order: { remark: "Test remark" }
    }, headers: { "HTTP_AUTHORIZATION" => @admin_auth }

    assert_equal "Test remark", @order.reload.remark
  end

  test "should destroy order" do
    assert_difference("Order.count", -1) do
      delete admin_order_path(@order), headers: { "HTTP_AUTHORIZATION" => @admin_auth }
    end

    assert_redirected_to admin_orders_path
    assert_equal "Pesanan berhasil dihapus!", flash[:notice]
  end

  test "should require authentication" do
    get admin_orders_path
    assert_response :unauthorized
  end

  test "should reject invalid credentials" do
    invalid_auth = ActionController::HttpAuthentication::Basic.encode_credentials("wrong", "wrong")
    get admin_orders_path, headers: { "HTTP_AUTHORIZATION" => invalid_auth }
    assert_response :unauthorized
  end

  test "should update tracking_number" do
    patch admin_order_path(@order), params: {
      order: { tracking_number: "JP123456789" }
    }, headers: { "HTTP_AUTHORIZATION" => @admin_auth }

    assert_redirected_to admin_order_path(@order)
    assert_equal "JP123456789", @order.reload.tracking_number
  end

  test "should set tracking_number_updated_at when tracking_number is updated" do
    assert_nil @order.tracking_number_updated_at

    patch admin_order_path(@order), params: {
      order: { tracking_number: "JP123456789" }
    }, headers: { "HTTP_AUTHORIZATION" => @admin_auth }

    assert_not_nil @order.reload.tracking_number_updated_at
  end
end
