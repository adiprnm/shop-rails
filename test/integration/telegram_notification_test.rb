require "test_helper"
require "mocha/minitest"

class TelegramNotificationIntegrationTest < ActionDispatch::IntegrationTest
  setup do
    @order = orders(:pending_order)
    Current.settings = {
      "payment_provider" => "midtrans",
      "telegram_enabled" => "true",
      "telegram_bot_token" => "test_token",
      "telegram_chat_id" => "test_chat_id"
    }
    Current.time_zone = "Asia/Jakarta"
  end

  test "sends telegram notification when order is paid" do
    TelegramNotificationJob.expects(:perform_later)
      .with(@order.id, :paid)

    @order.update(state: "paid")
  end

  test "sends telegram notification when order fails" do
    TelegramNotificationJob.expects(:perform_later)
      .with(@order.id, :failed)

    @order.update(state: "failed")
  end

  test "does not send telegram notification when disabled" do
    Current.settings["telegram_enabled"] = "false"

    TelegramNotificationJob.expects(:perform_later).never

    @order.update(state: "paid")
  end

  test "does not send telegram notification when bot token missing" do
    Current.settings["telegram_bot_token"] = nil

    TelegramNotificationJob.expects(:perform_later).never

    @order.update(state: "paid")
  end

  test "does not send telegram notification when chat id missing" do
    Current.settings["telegram_chat_id"] = nil

    TelegramNotificationJob.expects(:perform_later).never

    @order.update(state: "paid")
  end

  test "sends telegram notification for manual payment with evidence" do
    order = orders(:pending_order)
    Current.settings["payment_provider"] = "manual"

    evidence = order.payment_evidences.create(
      file: File.open(Rails.root.join("test/fixtures/files/test.pdf")),
      checked: true
    )

    TelegramNotificationJob.expects(:perform_later)
      .with(order.id, :paid)

    order.update(state: "paid")
  end

  test "sends telegram notification for manual payment without evidence" do
    order = orders(:pending_order)
    Current.settings["payment_provider"] = "manual"

    TelegramNotificationJob.expects(:perform_later)
      .with(order.id, :paid)

    order.update(state: "paid")
  end

  test "sends telegram notification for midtrans payment" do
    Current.settings["payment_provider"] = "midtrans"

    TelegramNotificationJob.expects(:perform_later)
      .with(@order.id, :paid)

    @order.update(state: "paid")
  end

  test "does not send telegram notification for expired order to paid transition" do
    order = orders(:expired_order)

    TelegramNotificationJob.expects(:perform_later)
      .with(order.id, :paid)
      .once

    order.update(state: "paid")
  end

  test "sends telegram notification when order expires" do
    order = orders(:pending_order)

    TelegramNotificationJob.expects(:perform_later)
      .with(order.id, :failed)

    order.update(state: "expired")
  end

  test "order notification service calls telegram methods" do
    notification = Order::Notification.with(order: @order)

    TelegramNotificationJob.expects(:perform_later)
      .with(@order.id, :paid)

    notification.notify_telegram_admin
  end

  test "order notification service calls telegram failed methods" do
    @order.update(state: "failed")
    notification = Order::Notification.with(order: @order)

    TelegramNotificationJob.expects(:perform_later)
      .with(@order.id, :failed)

    notification.notify_telegram_failed
  end

  test "telegram notifications are sent in addition to email notifications" do
    TelegramNotificationJob.expects(:perform_later)
      .with(@order.id, :paid)

    OrderMailer.any_instance.expects(:deliver_later)

    @order.update(state: "paid")
  end

  test "telegram notifications are sent for failed orders" do
    TelegramNotificationJob.expects(:perform_later)
      .with(@order.id, :failed)

    OrderMailer.any_instance.expects(:deliver_later)

    @order.update(state: "failed")
  end

  test "telegram_enabled? returns false when telegram_enabled is not 'true'" do
    Current.settings["telegram_enabled"] = "false"

    notification = Order::Notification.with(order: @order)
    refute notification.send(:telegram_enabled?)
  end

  test "telegram_enabled? returns true when all conditions are met" do
    Current.settings["telegram_enabled"] = "true"
    Current.settings["telegram_bot_token"] = "test_token"
    Current.settings["telegram_chat_id"] = "test_chat_id"

    notification = Order::Notification.with(order: @order)
    assert notification.send(:telegram_enabled?)
  end

  test "telegram_enabled? returns false when bot token is blank" do
    Current.settings["telegram_enabled"] = "true"
    Current.settings["telegram_bot_token"] = ""

    notification = Order::Notification.with(order: @order)
    refute notification.send(:telegram_enabled?)
  end

  test "telegram_enabled? returns false when chat id is blank" do
    Current.settings["telegram_enabled"] = "true"
    Current.settings["telegram_chat_id"] = ""

    notification = Order::Notification.with(order: @order)
    refute notification.send(:telegram_enabled?)
  end

  test "manual_payment_with_evidence? returns true for manual payment with evidence" do
    order = orders(:pending_order)
    Current.settings["payment_provider"] = "manual"

    order.payment_evidences.create(
      file: File.open(Rails.root.join("test/fixtures/files/test.pdf")),
      checked: true
    )

    job = TelegramNotificationJob.new
    order.instance_variable_set(:@order_id, order.id)

    assert job.send(:manual_payment_with_evidence?, order)
  end

  test "manual_payment_with_evidence? returns false for midtrans payment" do
    Current.settings["payment_provider"] = "midtrans"

    job = TelegramNotificationJob.new
    @order.instance_variable_set(:@order_id, @order.id)

    refute job.send(:manual_payment_with_evidence?, @order)
  end

  test "manual_payment_with_evidence? returns false for manual payment without evidence" do
    order = orders(:pending_order)
    Current.settings["payment_provider"] = "manual"

    job = TelegramNotificationJob.new
    order.instance_variable_set(:@order_id, order.id)

    refute job.send(:manual_payment_with_evidence?, order)
  end
end
