require "test_helper"
require "mocha/minitest"

class DonationNotificationJobTest < ActiveJob::TestCase
  setup do
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
    assert_enqueued_with(job: DonationNotificationJob) do
      DonationNotificationJob.perform_later(@donation.id, :paid)
    end
  end

  test "sends paid notification" do
    TelegramClient.any_instance.expects(:send_message)
      .with(kind_of(String), parse_mode: "Markdown")
      .returns(success: true)

    DonationNotificationJob.perform_now(@donation.id, :paid)
  end

  test "sends failed notification" do
    @donation.update(state: "failed")

    TelegramClient.any_instance.expects(:send_message)
      .with(kind_of(String), parse_mode: "Markdown")
      .returns(success: true)

    DonationNotificationJob.perform_now(@donation.id, :failed)
  end

  test "sends paid notification with photo for manual payment with evidence" do
    donation = donations(:named_donation)
    donation.update(state: "paid")
    Current.settings["payment_provider"] = "manual"

    evidence = donation.payment_evidences.create(
      file: File.open(Rails.root.join("test/fixtures/files/test.pdf")),
      checked: true
    )

    TelegramClient.any_instance.expects(:send_photo)
      .with(kind_of(String), caption: kind_of(String), parse_mode: "Markdown")
      .returns(success: true)

    DonationNotificationJob.perform_now(donation.id, :paid)
  end

  test "sends text message for manual payment without evidence" do
    donation = donations(:named_donation)
    Current.settings["payment_provider"] = "manual"

    TelegramClient.any_instance.expects(:send_message)
      .with(kind_of(String), parse_mode: "Markdown")
      .returns(success: true)

    DonationNotificationJob.perform_now(donation.id, :paid)
  end

  test "formats paid message correctly" do
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
      assert_includes message, "*Date*"
      assert options[:parse_mode] == "Markdown"
      { success: true }
    end

    DonationNotificationJob.perform_now(donation.id, :paid)
  end

  test "formats failed message correctly" do
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

    DonationNotificationJob.perform_now(donation.id, :failed)
  end

  test "handles failed payment reason correctly" do
    donation = donations(:named_donation)
    donation.update(state: "failed")

    TelegramClient.any_instance.expects(:send_message) do |message, options|
      assert_includes message, "*Reason*"
      assert_includes message, "Payment Failed"
      { success: true }
    end

    DonationNotificationJob.perform_now(donation.id, :failed)
  end

  test "formats currency correctly" do
    donation = donations(:named_donation)
    donation.update(amount: 150000)

    TelegramClient.any_instance.expects(:send_message) do |message, options|
      assert_includes message, "Rp 150.000"
      { success: true }
    end

    DonationNotificationJob.perform_now(donation.id, :paid)
  end

  test "includes message in notification" do
    donation = donations(:named_donation)

    TelegramClient.any_instance.expects(:send_message) do |message, options|
      assert_includes message, donation.message
      { success: true }
    end

    DonationNotificationJob.perform_now(donation.id, :paid)
  end

  test "includes timestamp in message" do
    donation = donations(:named_donation)
    timestamp = donation.state_updated_at.strftime("%Y-%m-%d %H:%M")

    TelegramClient.any_instance.expects(:send_message) do |message, options|
      assert_includes message, timestamp
      { success: true }
    end

    DonationNotificationJob.perform_now(donation.id, :paid)
  end

  test "includes manual payment approval notice" do
    donation = donations(:named_donation)
    Current.settings["payment_provider"] = "manual"

    TelegramClient.any_instance.expects(:send_message) do |message, options|
      assert_includes message, "⚠️ *Payment waiting for approval*"
      assert_includes message, "Please review and approve this manual payment"
      { success: true }
    end

    DonationNotificationJob.perform_now(donation.id, :paid)
  end

  test "does not include manual payment notice for midtrans" do
    donation = donations(:named_donation)
    Current.settings["payment_provider"] = "midtrans"

    TelegramClient.any_instance.expects(:send_message) do |message, options|
      refute_includes message, "Payment waiting for approval"
      { success: true }
    end

    DonationNotificationJob.perform_now(donation.id, :paid)
  end

  test "sends evidence uploaded notification" do
    donation = donations(:named_donation)
    donation.payment_evidences.create(
      file: File.open(Rails.root.join("test/fixtures/files/test.pdf")),
      checked: true
    )

    TelegramClient.any_instance.expects(:send_photo)
      .with(kind_of(String), caption: kind_of(String), parse_mode: "Markdown")
      .returns(success: true)

    DonationNotificationJob.perform_now(donation.id, :evidence_uploaded)
  end

  test "evidence uploaded notification has correct format" do
    donation = donations(:named_donation)
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

    DonationNotificationJob.perform_now(donation.id, :evidence_uploaded)
  end

  test "does not send evidence uploaded notification without evidence" do
    donation = donations(:named_donation)

    TelegramClient.any_instance.expects(:send_photo).never
    TelegramClient.any_instance.expects(:send_message).never

    DonationNotificationJob.perform_now(donation.id, :evidence_uploaded)
  end

  test "handles donation not found error" do
    donation_id = 999999

    TelegramClient.any_instance.expects(:send_message).never

    DonationNotificationJob.perform_now(donation_id, :paid)
  end

  test "handles telegram client errors gracefully" do
    TelegramClient.any_instance.expects(:send_message)
      .returns(success: false, error: "Telegram API Error")

    DonationNotificationJob.perform_now(@donation.id, :paid)
  end

  test "handles network errors with retry" do
    TelegramClient.any_instance.expects(:send_message)
      .raises(Errno::ECONNREFUSED.new("Connection refused"))

    assert_raises(Errno::ECONNREFUSED) do
      DonationNotificationJob.perform_now(@donation.id, :paid)
    end
  end
end
