require "test_helper"

class OrderMailerTest < ActionMailer::TestCase
  setup do
    @order = orders(:pending_order)
    @line_items = @order.line_items.to_a
  end

  test "should send shipping tracking email" do
    email = OrderMailer.with(order: @order, products: @line_items).shipping_tracking

    assert_equal "Pesanan kamu sudah dikirim!", email.subject
    assert_equal [ @order.customer_email_address ], email.to
    assert_match(/Nomor Resi/, email.body.encoded)
  end

  test "should include tracking number in shipping tracking email" do
    @order.update(tracking_number: "JP123456789")
    email = OrderMailer.with(order: @order, products: @line_items).shipping_tracking

    assert_match(/JP123456789/, email.body.encoded)
  end

  test "should include shipping information in shipping tracking email" do
    email = OrderMailer.with(order: @order, products: @line_items).shipping_tracking

    assert_match(/Kurir/, email.body.encoded)
    assert_match(/Alamat Pengiriman/, email.body.encoded)
  end
end
