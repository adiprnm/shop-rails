require "test_helper"

class Transaction::Payment::MidtransTest < ActiveSupport::TestCase
  setup do
    Current.settings = {
      "payment_provider" => "midtrans",
      "payment_client_secret" => "test_secret",
      "payment_api_host" => "https://api.sandbox.midtrans.com"
    }
  end

  test "order_payment_url_params includes shipping cost in item_details when shipping_cost > 0" do
    order = orders(:paid_order)
    order.update(total_price: 308000, shipping_cost: 9000)

    midtrans_payment = Transaction::Payment::Midtrans.new(order)
    params = midtrans_payment.order_payment_url_params

    assert_equal 308000, params[:transaction_details][:gross_amount]

    item_details = params[:item_details]
    assert_equal 3, item_details.count

    shipping_item = item_details.find { |item| item[:name] == "Ongkos Kirim" }
    assert_not_nil shipping_item
    assert_equal 9000, shipping_item[:price]

    total_item_details = item_details.sum { |item| item[:price] * item[:quantity] }
    assert_equal params[:transaction_details][:gross_amount], total_item_details
  end

  test "order_payment_url_params does not include shipping cost in item_details when shipping_cost is zero" do
    order = orders(:paid_order)
    order.update(total_price: 299000, shipping_cost: 0)

    midtrans_payment = Transaction::Payment::Midtrans.new(order)
    params = midtrans_payment.order_payment_url_params

    assert_equal 299000, params[:transaction_details][:gross_amount]

    item_details = params[:item_details]
    assert_equal 2, item_details.count

    assert_nil item_details.find { |item| item[:name] == "Ongkos Kirim" }

    total_item_details = item_details.sum { |item| item[:price] * item[:quantity] }
    assert_equal params[:transaction_details][:gross_amount], total_item_details
  end

  test "order_payment_url_params includes shipping cost with correct courier name" do
    order = orders(:paid_order)
    order.update(total_price: 308000, shipping_cost: 9000, shipping_provider: "JNE", shipping_method: "YES")

    midtrans_payment = Transaction::Payment::Midtrans.new(order)
    params = midtrans_payment.order_payment_url_params

    shipping_item = params[:item_details].find { |item| item[:name] == "Ongkos Kirim (JNE - YES)" }
    assert_not_nil shipping_item
    assert_equal 9000, shipping_item[:price]
  end

  test "order_payment_url_params sum of item_details equals gross_amount with multiple items and shipping" do
    order = orders(:paid_order)
    order.update(total_price: 308000, shipping_cost: 9000)

    midtrans_payment = Transaction::Payment::Midtrans.new(order)
    params = midtrans_payment.order_payment_url_params

    assert_equal 308000, params[:transaction_details][:gross_amount]

    total_item_details = params[:item_details].sum { |item| item[:price] * item[:quantity] }
    assert_equal params[:transaction_details][:gross_amount], total_item_details
  end

  test "donation_payment_url_params item_details sum equals gross_amount" do
    donation = donations(:named_donation)
    donation.update(amount: 100000)

    midtrans_payment = Transaction::Payment::Midtrans.new(donation)
    params = midtrans_payment.donation_payment_url_params

    assert_equal 100000, params[:transaction_details][:gross_amount]

    total_item_details = params[:item_details].sum { |item| item[:price] * item[:quantity] }
    assert_equal params[:transaction_details][:gross_amount], total_item_details
  end
end
