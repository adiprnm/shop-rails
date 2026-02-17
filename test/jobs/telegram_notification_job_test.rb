require "test_helper"
require "mocha/minitest"

class TelegramNotificationJobTest < ActiveJob::TestCase
  setup do
    @order = orders(:paid_order)
    @donation = donations(:named_donation)
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
      TelegramNotificationJob.perform_later(@order, :paid)
    end
  end

  test "sends paid notification for order" do
    TelegramClient.any_instance.expects(:send_message)
      .with(kind_of(String), parse_mode: "Markdown")
      .returns(success: true)

    TelegramNotificationJob.perform_now(@order, :paid)
  end

  test "sends paid notification for donation" do
    TelegramClient.any_instance.expects(:send_message)
      .with(kind_of(String), parse_mode: "Markdown")
      .returns(success: true)

    TelegramNotificationJob.perform_now(@donation, :paid)
  end

  test "sends failed notification for order" do
    @order.update(state: "failed")

    TelegramClient.any_instance.expects(:send_message)
      .with(kind_of(String), parse_mode: "Markdown")
      .returns(success: true)

    TelegramNotificationJob.perform_now(@order, :failed)
  end

  test "sends failed notification for donation" do
    @donation.update(state: "failed")

    TelegramClient.any_instance.expects(:send_message)
      .with(kind_of(String), parse_mode: "Markdown")
      .returns(success: true)

    TelegramNotificationJob.perform_now(@donation, :failed)
  end

  test "sends paid notification with photo for manual order payment with evidence" do
    order = orders(:pending_order)
    order.update(state: "paid")
    Current.settings["payment_provider"] = "manual"

    evidence = order.payment_evidences.create(
      file: File.open(Rails.root.join("test/fixtures/files/test.pdf")),
      checked: true
    )

    TelegramClient.any_instance.expects(:send_message)
      .with(kind_of(String), parse_mode: "Markdown")
      .returns(success: true)

    TelegramNotificationJob.perform_now(order, :paid)
  end

  test "sends paid notification with photo for manual donation payment with evidence" do
    donation = donations(:named_donation)
    donation.update(state: "paid")
    Current.settings["payment_provider"] = "manual"

    evidence = donation.payment_evidences.create(
      file: File.open(Rails.root.join("test/fixtures/files/test.pdf")),
      checked: true
    )

    TelegramClient.any_instance.expects(:send_message)
      .with(kind_of(String), parse_mode: "Markdown")
      .returns(success: true)

    TelegramNotificationJob.perform_now(donation, :paid)
  end

  test "sends text message for manual order payment without evidence" do
    order = orders(:paid_order)
    Current.settings["payment_provider"] = "manual"

    TelegramClient.any_instance.expects(:send_message)
      .with(kind_of(String), parse_mode: "Markdown")
      .returns(success: true)

    TelegramNotificationJob.perform_now(order, :paid)
  end

  test "sends text message for manual donation payment without evidence" do
    donation = donations(:named_donation)
    Current.settings["payment_provider"] = "manual"

    TelegramClient.any_instance.expects(:send_message)
      .with(kind_of(String), parse_mode: "Markdown")
      .returns(success: true)

    TelegramNotificationJob.perform_now(donation, :paid)
  end

  test "formats order paid message correctly" do
    order = orders(:paid_order)

    TelegramClient.any_instance.expects(:send_message) do |message, options|
      assert_includes message, "🔔 *New Order Paid*"
      assert_includes message, "*Order*"
      assert_includes message, "##{order.order_id}"
      assert_includes message, "*Customer*"
      assert_includes message, order.customer_name
      assert_includes message, "*Total*"
      assert_includes message, "Rp#{order.total_price.to_s.reverse.scan(/.{1,3}/).join(".").reverse}"
      assert_includes message, "*Payment*"
      assert_includes message, "Midtrans"
      assert options[:parse_mode] == "Markdown"
      { success: true }
    end

    TelegramNotificationJob.perform_now(order, :paid)
  end

  test "formats donation paid message correctly" do
    donation = donations(:named_donation)

    TelegramClient.any_instance.expects(:send_message) do |message, options|
      assert_includes message, "🔔 *New Donation Paid*"
      assert_includes message, "*Donation*"
      assert_includes message, "##{donation.donation_id}"
      assert_includes message, "*Donor*"
      assert_includes message, donation.name
      assert_includes message, "*Amount*"
      assert_includes message, "*Message*"
      assert_includes message, "*Payment*"
      assert_includes message, "Midtrans"
      assert options[:parse_mode] == "Markdown"
      { success: true }
    end

    TelegramNotificationJob.perform_now(donation, :paid)
  end

  test "formats order failed message correctly" do
    order = orders(:expired_order)

    TelegramClient.any_instance.expects(:send_message) do |message, options|
      assert_includes message, "⚠️ *Order Failed*"
      assert_includes message, "*Order*"
      assert_includes message, "##{order.order_id}"
      assert_includes message, "*Customer*"
      assert_includes message, order.customer_name
      assert_includes message, "*Reason*"
      assert_includes message, "Payment Expired"
      assert options[:parse_mode] == "Markdown"
      { success: true }
    end

    TelegramNotificationJob.perform_now(order, :failed)
  end

  test "formats donation failed message correctly" do
    donation = donations(:named_donation)
    donation.update(state: "expired")

    TelegramClient.any_instance.expects(:send_message) do |message, options|
      assert_includes message, "⚠️ *Donation Failed*"
      assert_includes message, "*Donation*"
      assert_includes message, "##{donation.donation_id}"
      assert_includes message, "*Donor*"
      assert_includes message, donation.name
      assert_includes message, "*Amount*"
      assert_includes message, "*Reason*"
      assert_includes message, "Payment Expired"
      assert options[:parse_mode] == "Markdown"
      { success: true }
    end

    TelegramNotificationJob.perform_now(donation, :failed)
  end

  test "handles failed order payment reason correctly" do
    order = orders(:pending_order)
    order.update(state: "failed")

    TelegramClient.any_instance.expects(:send_message) do |message, options|
      assert_includes message, "*Reason*"
      assert_includes message, "Payment Failed"
      { success: true }
    end

    TelegramNotificationJob.perform_now(order, :failed)
  end

  test "handles failed donation payment reason correctly" do
    donation = donations(:named_donation)
    donation.update(state: "failed")

    TelegramClient.any_instance.expects(:send_message) do |message, options|
      assert_includes message, "*Reason*"
      assert_includes message, "Payment Failed"
      { success: true }
    end

    TelegramNotificationJob.perform_now(donation, :failed)
  end

  test "formats currency correctly" do
    order = orders(:paid_order)
    order.update(total_price: 150000)

    TelegramClient.any_instance.expects(:send_message) do |message, options|
      assert_includes message, "Rp150.000"
      { success: true }
    end

    TelegramNotificationJob.perform_now(order, :paid)
  end

  test "includes order product names in message" do
    order = orders(:paid_order)
    products = order.line_items.map(&:orderable_name).join(", ")

    TelegramClient.any_instance.expects(:send_message) do |message, options|
      assert_includes message, products
      { success: true }
    end

    TelegramNotificationJob.perform_now(order, :paid)
  end

  test "includes donation message in notification" do
    donation = donations(:named_donation)

    TelegramClient.any_instance.expects(:send_message) do |message, options|
      assert_includes message, donation.message
      { success: true }
    end

    TelegramNotificationJob.perform_now(donation, :paid)
  end

  test "includes timestamp in message" do
    order = orders(:paid_order)
    timestamp = I18n.l order.state_updated_at, locale: :id, format: :long

    TelegramClient.any_instance.expects(:send_message) do |message, options|
      assert_includes message, timestamp
      { success: true }
    end

    TelegramNotificationJob.perform_now(order, :paid)
  end

  test "does not include manual payment approval notice for order" do
    order = orders(:paid_order)
    Current.settings["payment_provider"] = "manual"

    TelegramClient.any_instance.expects(:send_message) do |message, options|
      refute_includes message, "Payment waiting for approval"
      refute_includes message, "Please review and approve this manual payment"
      { success: true }
    end

    TelegramNotificationJob.perform_now(order, :paid)
  end

  test "does not include manual payment approval notice for donation" do
    donation = donations(:named_donation)
    Current.settings["payment_provider"] = "manual"

    TelegramClient.any_instance.expects(:send_message) do |message, options|
      refute_includes message, "Payment waiting for approval"
      refute_includes message, "Please review and approve this manual payment"
      { success: true }
    end

    TelegramNotificationJob.perform_now(donation, :paid)
  end

  test "does not include manual payment notice for order midtrans" do
    order = orders(:paid_order)
    Current.settings["payment_provider"] = "midtrans"

    TelegramClient.any_instance.expects(:send_message) do |message, options|
      refute_includes message, "Payment waiting for approval"
      { success: true }
    end

    TelegramNotificationJob.perform_now(order, :paid)
  end

  test "does not include manual payment notice for donation midtrans" do
    donation = donations(:named_donation)
    Current.settings["payment_provider"] = "midtrans"

    TelegramClient.any_instance.expects(:send_message) do |message, options|
      refute_includes message, "Payment waiting for approval"
      { success: true }
    end

    TelegramNotificationJob.perform_now(donation, :paid)
  end

  test "sends order evidence uploaded notification" do
    order = orders(:paid_order)
    Current.settings["payment_provider"] = "manual"
    order.payment_evidences.create(
      file: File.open(Rails.root.join("test/fixtures/files/test.pdf")),
      checked: true
    )

    TelegramClient.any_instance.expects(:send_photo)
      .with(kind_of(String), caption: kind_of(String), parse_mode: "Markdown", reply_markup: kind_of(String))
      .returns(success: true)

    TelegramNotificationJob.perform_now(order, :evidence_uploaded)
  end

  test "sends donation evidence uploaded notification" do
    donation = donations(:named_donation)
    Current.settings["payment_provider"] = "manual"
    donation.payment_evidences.create(
      file: File.open(Rails.root.join("test/fixtures/files/test.pdf")),
      checked: true
    )

    TelegramClient.any_instance.expects(:send_photo)
      .with(kind_of(String), caption: kind_of(String), parse_mode: "Markdown", reply_markup: kind_of(String))
      .returns(success: true)

    TelegramNotificationJob.perform_now(donation, :evidence_uploaded)
  end

  test "order evidence uploaded notification has correct format" do
    order = orders(:paid_order)
    Current.settings["payment_provider"] = "manual"
    order.payment_evidences.create(
      file: File.open(Rails.root.join("test/fixtures/files/test.pdf")),
      checked: true
    )

    TelegramClient.any_instance.expects(:send_photo) do |file_path, options|
      assert_includes options[:caption], "📎 *Payment Evidence Uploaded*"
      assert_includes options[:caption], "*Order*"
      assert_includes options[:caption], "##{order.order_id}"
      assert_includes options[:caption], "*Customer*"
      assert_includes options[:caption], order.customer_name
      assert_includes options[:caption], "*Products*"
      assert_includes options[:caption], "*Total*"
      assert_includes options[:caption], "*Date*"
      assert_includes options[:caption], "⚠️ *Payment waiting for approval*"
      assert options[:parse_mode] == "Markdown"
      { success: true }
    end

    TelegramNotificationJob.perform_now(order, :evidence_uploaded)
  end

  test "donation evidence uploaded notification has correct format" do
    donation = donations(:named_donation)
    Current.settings["payment_provider"] = "manual"
    donation.payment_evidences.create(
      file: File.open(Rails.root.join("test/fixtures/files/test.pdf")),
      checked: true
    )

    TelegramClient.any_instance.expects(:send_photo) do |file_path, options|
      assert_includes options[:caption], "📎 *Payment Evidence Uploaded*"
      assert_includes options[:caption], "*Donation*"
      assert_includes options[:caption], "##{donation.donation_id}"
      assert_includes options[:caption], "*Donor*"
      assert_includes options[:caption], donation.name
      assert_includes options[:caption], "*Amount*"
      assert_includes options[:caption], "*Message*"
      assert_includes options[:caption], "*Date*"
      assert_includes options[:caption], "⚠️ *Payment waiting for approval*"
      assert options[:parse_mode] == "Markdown"
      { success: true }
    end

    TelegramNotificationJob.perform_now(donation, :evidence_uploaded)
  end

  test "does not send order evidence uploaded notification without evidence" do
    order = orders(:paid_order)

    TelegramClient.any_instance.expects(:send_photo).never
    TelegramClient.any_instance.expects(:send_message).never

    TelegramNotificationJob.perform_now(order, :evidence_uploaded)
  end

  test "does not send donation evidence uploaded notification without evidence" do
    donation = donations(:named_donation)

    TelegramClient.any_instance.expects(:send_photo).never
    TelegramClient.any_instance.expects(:send_message).never

    TelegramNotificationJob.perform_now(donation, :evidence_uploaded)
  end

  test "handles telegram client errors gracefully" do
    TelegramClient.any_instance.expects(:send_message)
      .returns(success: false, error: "Telegram API Error")

    TelegramNotificationJob.perform_now(@order, :paid)
  end

  test "handles network errors with retry" do
    TelegramClient.any_instance.expects(:send_message)
      .raises(Errno::ECONNREFUSED.new("Connection refused"))

    assert_raises(Errno::ECONNREFUSED) do
      TelegramNotificationJob.perform_now(@order, :paid)
    end
  end

  test "creates temp file for order payment evidence" do
    order = orders(:pending_order)
    order.update(state: "paid")
    Current.settings["payment_provider"] = "manual"

    evidence = order.payment_evidences.create(
      file: File.open(Rails.root.join("test/fixtures/files/test.pdf")),
      checked: true
    )

    TelegramClient.any_instance.expects(:send_message).returns(success: true)

    TelegramNotificationJob.perform_now(order, :paid)
  end

  test "logs errors for failed telegram requests" do
    TelegramClient.any_instance.expects(:send_message)
      .returns(success: false, error: "API Error")

    TelegramNotificationJob.perform_now(@order, :paid)
  end

  test "does not include inline keyboard for manual order payment" do
    order = orders(:paid_order)
    Current.settings["payment_provider"] = "manual"

    TelegramClient.any_instance.expects(:send_message) do |message, options|
      refute options[:reply_markup]
      { success: true }
    end

    TelegramNotificationJob.perform_now(order, :paid)
  end

  test "does not include inline keyboard for manual donation payment" do
    donation = donations(:named_donation)
    Current.settings["payment_provider"] = "manual"

    TelegramClient.any_instance.expects(:send_message) do |message, options|
      refute options[:reply_markup]
      { success: true }
    end

    TelegramNotificationJob.perform_now(donation, :paid)
  end

  test "does not include inline keyboard for midtrans payment" do
    order = orders(:paid_order)
    Current.settings["payment_provider"] = "midtrans"

    TelegramClient.any_instance.expects(:send_message) do |message, options|
      refute options[:reply_markup]
      { success: true }
    end

    TelegramNotificationJob.perform_now(order, :paid)
  end
end
