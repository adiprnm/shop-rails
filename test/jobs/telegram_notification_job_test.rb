require "test_helper"
require "mocha/minitest"

class TelegramNotificationJobTest < ActiveJob::TestCase
  setup do
    @order = orders(:paid_order)
    Current.settings = {
      "payment_provider" => "midtrans",
      "telegram_enabled" => "true",
      "telegram_bot_token" => "test_token",
      "telegram_chat_id" => "test_chat_id"
    }
    Current.time_zone = "Asia/Jakarta"
  end

  test "job is queued in default queue" do
    assert_enqueued_with(job: TelegramNotificationJob) do
      TelegramNotificationJob.perform_later(@order.id, :paid)
    end
  end

  test "sends paid notification" do
    TelegramClient.any_instance.expects(:send_message)
      .with(kind_of(String), parse_mode: "Markdown")
      .returns(success: true)

    TelegramNotificationJob.perform_now(@order.id, :paid)
  end

  test "sends failed notification" do
    @order.update(state: "failed")

    TelegramClient.any_instance.expects(:send_message)
      .with(kind_of(String), parse_mode: "Markdown")
      .returns(success: true)

    TelegramNotificationJob.perform_now(@order.id, :failed)
  end

  test "sends paid notification with photo for manual payment with evidence" do
    order = orders(:pending_order)
    order.update(state: "paid")
    Current.settings["payment_provider"] = "manual"

    evidence = order.payment_evidences.create(
      file: File.open(Rails.root.join("test/fixtures/files/test.pdf")),
      checked: true
    )

    TelegramClient.any_instance.expects(:send_photo)
      .with(kind_of(String), caption: kind_of(String), parse_mode: "Markdown")
      .returns(success: true)

    TelegramNotificationJob.perform_now(order.id, :paid)
  end

  test "sends text message for manual payment without evidence" do
    order = orders(:paid_order)
    Current.settings["payment_provider"] = "manual"

    TelegramClient.any_instance.expects(:send_message)
      .with(kind_of(String), parse_mode: "Markdown")
      .returns(success: true)

    TelegramNotificationJob.perform_now(order.id, :paid)
  end

  test "formats paid message correctly" do
    order = orders(:paid_order)
    job = TelegramNotificationJob.new

    TelegramClient.any_instance.expects(:send_message) do |message, options|
      assert_includes message, "🔔 *New Order Paid*"
      assert_includes message, "Order: ##{order.order_id}"
      assert_includes message, "Customer: #{order.customer_name}"
      assert_includes message, "Total: Rp #{order.total_price.to_s.reverse.scan(/.{1,3}/).join(".").reverse}"
      assert_includes message, "Payment: Midtrans"
      assert options[:parse_mode] == "Markdown"
      { success: true }
    end

    job.perform_now(order.id, :paid)
  end

  test "formats failed message correctly" do
    order = orders(:expired_order)

    TelegramClient.any_instance.expects(:send_message) do |message, options|
      assert_includes message, "⚠️ *Order Failed*"
      assert_includes message, "Order: ##{order.order_id}"
      assert_includes message, "Customer: #{order.customer_name}"
      assert_includes message, "Reason: Payment Expired"
      assert options[:parse_mode] == "Markdown"
      { success: true }
    end

    TelegramNotificationJob.perform_now(order.id, :failed)
  end

  test "handles failed payment reason correctly" do
    order = orders(:pending_order)
    order.update(state: "failed")

    TelegramClient.any_instance.expects(:send_message) do |message, options|
      assert_includes message, "Reason: Payment Failed"
      { success: true }
    end

    TelegramNotificationJob.perform_now(order.id, :failed)
  end

  test "formats currency correctly" do
    order = orders(:paid_order)
    order.update(total_price: 150000)

    TelegramClient.any_instance.expects(:send_message) do |message, options|
      assert_includes message, "Total: Rp 150.000"
      { success: true }
    end

    TelegramNotificationJob.perform_now(order.id, :paid)
  end

  test "includes product names in message" do
    order = orders(:paid_order)
    products = order.line_items.map(&:orderable_name).join(", ")

    TelegramClient.any_instance.expects(:send_message) do |message, options|
      assert_includes message, products
      { success: true }
    end

    TelegramNotificationJob.perform_now(order.id, :paid)
  end

  test "includes timestamp in message" do
    order = orders(:paid_order)
    timestamp = order.state_updated_at.strftime("%Y-%m-%d %H:%M")

    TelegramClient.any_instance.expects(:send_message) do |message, options|
      assert_includes message, timestamp
      { success: true }
    end

    TelegramNotificationJob.perform_now(order.id, :paid)
  end

  test "handles order not found error" do
    order_id = 999999

    TelegramClient.any_instance.expects(:send_message).never

    TelegramNotificationJob.perform_now(order_id, :paid)
  end

  test "handles telegram client errors gracefully" do
    TelegramClient.any_instance.expects(:send_message)
      .returns(success: false, error: "Telegram API Error")

    TelegramNotificationJob.perform_now(@order.id, :paid)
  end

  test "handles network errors with retry" do
    TelegramClient.any_instance.expects(:send_message)
      .raises(Errno::ECONNREFUSED.new("Connection refused"))

    assert_raises(Errno::ECONNREFUSED) do
      TelegramNotificationJob.perform_now(@order.id, :paid)
    end
  end

  test "creates temp file for payment evidence" do
    order = orders(:pending_order)
    order.update(state: "paid")
    Current.settings["payment_provider"] = "manual"

    evidence = order.payment_evidences.create(
      file: File.open(Rails.root.join("test/fixtures/files/test.pdf")),
      checked: true
    )

    Tempfile.expects(:create).with(kind_of(Array)).yields(File.new(Dir.tmpdir + "/test", "w"))

    TelegramClient.any_instance.expects(:send_photo).returns(success: true)

    TelegramNotificationJob.perform_now(order.id, :paid)
  end

  test "does not send notification when order not found" do
    Rails.logger.expects(:error).with(kind_of(String))

    TelegramNotificationJob.perform_now(999999, :paid)
  end

  test "logs errors for failed telegram requests" do
    TelegramClient.any_instance.expects(:send_message)
      .returns(success: false, error: "API Error")

    Rails.logger.expects(:error).with(kind_of(String))

    TelegramNotificationJob.perform_now(@order.id, :paid)
  end
end
