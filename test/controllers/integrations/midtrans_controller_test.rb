require "test_helper"

class Integrations::MidtransControllerTest < ActionDispatch::IntegrationTest
  setup do
    Current.settings = { "payment_client_secret" => "test_secret" }
    @order = orders(:paid_order)
    @donation = donations(:named_donation)
  end

  test "should return OK for test payment" do
    post payment_integrations_midtrans_path, params: {
      order_id: "payment_notif_test_order_id"
    }

    assert_response :success
    assert_equal "OK", JSON.parse(response.body)["message"]
  end

  test "should update order state to paid" do
    @order.update(state: "pending")
    valid_signature = Digest::SHA2.new(512).hexdigest("#{@order.order_id}200149000test_secret")

    post payment_integrations_midtrans_path, params: {
      order_id: @order.order_id,
      status_code: "200",
      gross_amount: 149000,
      transaction_status: "settlement",
      signature_key: valid_signature,
      fraud_status: "accept"
    }

    assert_response :success
    assert_equal "paid", @order.reload.state
  end

  test "should update donation state to paid" do
    @donation.update(state: "pending")
    valid_signature = Digest::SHA2.new(512).hexdigest("#{@donation.donation_id}200100000test_secret")

    post payment_integrations_midtrans_path, params: {
      order_id: @donation.donation_id,
      status_code: "200",
      gross_amount: 100000,
      transaction_status: "settlement",
      signature_key: valid_signature,
      fraud_status: "accept"
    }

    assert_response :success
    assert_equal "paid", @donation.reload.state
  end

  test "should update order state to failed" do
    @order.update(state: "pending")
    valid_signature = Digest::SHA2.new(512).hexdigest("#{@order.order_id}202149000test_secret")

    post payment_integrations_midtrans_path, params: {
      order_id: @order.order_id,
      status_code: "202",
      gross_amount: 149000,
      transaction_status: "deny",
      signature_key: valid_signature,
      fraud_status: "accept"
    }

    assert_response :success
    assert_equal "failed", @order.reload.state
  end

  test "should update order state to expired" do
    @order.update(state: "pending")
    valid_signature = Digest::SHA2.new(512).hexdigest("#{@order.order_id}202149000test_secret")

    post payment_integrations_midtrans_path, params: {
      order_id: @order.order_id,
      status_code: "202",
      gross_amount: 149000,
      transaction_status: "expire",
      signature_key: valid_signature,
      fraud_status: "accept"
    }

    assert_response :success
    assert_equal "expired", @order.reload.state
  end

  test "should return unauthorized for invalid signature" do
    post payment_integrations_midtrans_path, params: {
      order_id: @order.order_id,
      status_code: "200",
      gross_amount: 149000,
      transaction_status: "settlement",
      signature_key: "invalid_signature",
      fraud_status: "accept"
    }

    assert_response :unauthorized
    assert_equal "Invalid signature", JSON.parse(response.body)["message"]
  end

  test "should return unauthorized for fraud detected" do
    valid_signature = Digest::SHA2.new(512).hexdigest("#{@order.order_id}200149000test_secret")

    post payment_integrations_midtrans_path, params: {
      order_id: @order.order_id,
      status_code: "200",
      gross_amount: 149000,
      transaction_status: "settlement",
      signature_key: valid_signature,
      fraud_status: "deny"
    }

    assert_response :unauthorized
    assert_equal "Fraud detected!", JSON.parse(response.body)["message"]
  end

  test "should return not found for non-existent order" do
    valid_signature = Digest::SHA2.new(512).hexdigest("non-existent-id200149000test_secret")

    post payment_integrations_midtrans_path, params: {
      order_id: "non-existent-id",
      status_code: "200",
      gross_amount: 149000,
      transaction_status: "settlement",
      signature_key: valid_signature,
      fraud_status: "accept"
    }

    assert_response :not_found
    assert_equal "Order/donation not found!", JSON.parse(response.body)["message"]
  end

  test "should skip verify_authenticity_token" do
    assert_no_difference("ActionController::RequestForgeryProtection") do
      post payment_integrations_midtrans_path, params: {
        order_id: "payment_notif_test_order_id"
      }
    end
  end

  test "should update integration_data" do
    @order.update(state: "pending")
    valid_signature = Digest::SHA2.new(512).hexdigest("#{@order.order_id}200149000test_secret")
    params = {
      order_id: @order.order_id,
      status_code: "200",
      gross_amount: 149000,
      transaction_status: "settlement",
      signature_key: valid_signature,
      fraud_status: "accept",
      payment_type: "credit_card"
    }

    post payment_integrations_midtrans_path, params: params

    assert_not_nil @order.reload.integration_data
    assert_equal "credit_card", @order.reload.integration_data["payment_type"]
  end

  test "should handle pending transaction status" do
    @order.update(state: "pending")
    valid_signature = Digest::SHA2.new(512).hexdigest("#{@order.order_id}201149000test_secret")

    post payment_integrations_midtrans_path, params: {
      order_id: @order.order_id,
      status_code: "201",
      gross_amount: 149000,
      transaction_status: "pending",
      signature_key: valid_signature,
      fraud_status: "accept"
    }

    assert_response :success
    assert_equal "pending", @order.reload.state
  end

  test "should handle cancel transaction status" do
    @order.update(state: "pending")
    valid_signature = Digest::SHA2.new(512).hexdigest("#{@order.order_id}201149000test_secret")

    post payment_integrations_midtrans_path, params: {
      order_id: @order.order_id,
      status_code: "201",
      gross_amount: 149000,
      transaction_status: "cancel",
      signature_key: valid_signature,
      fraud_status: "accept"
    }

    assert_response :success
    assert_equal "pending", @order.reload.state
  end
end
