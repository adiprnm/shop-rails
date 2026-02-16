require "test_helper"
require "mocha/minitest"

class Integrations::TelegramWebhooksControllerTest < ActionDispatch::IntegrationTest
  setup do
    @order = orders(:pending_order)
    @donation = donations(:named_donation)
    @donation.update(state: "pending")

    Current.settings = {
      "telegram_webhook_secret_token" => nil
    }
  end

  test "responds with ok to valid callback query" do
    callback_query = {
      id: "123",
      data: "approve:order:#{@order.order_id}",
      message: { chat: { id: "test_chat_id" } }
    }

    post integrations_telegram_webhooks_path, params: { callback_query: callback_query }
    assert_response :ok
  end

  test "approves order payment through callback" do
    callback_query = {
      id: "123",
      data: "approve:order:#{@order.order_id}",
      message: { chat: { id: "test_chat_id" } }
    }

    TelegramClient.any_instance.expects(:answer_callback_query)
      .with("123", text: "Payment approved successfully!", show_alert: false)
      .returns(success: true)

    post integrations_telegram_webhooks_path, params: { callback_query: callback_query }

    @order.reload
    assert_equal "paid", @order.state
  end

  test "approves donation payment through callback" do
    callback_query = {
      id: "123",
      data: "approve:donation:#{@donation.donation_id}",
      message: { chat: { id: "test_chat_id" } }
    }

    TelegramClient.any_instance.expects(:answer_callback_query)
      .with("123", text: "Payment approved successfully!", show_alert: false)
      .returns(success: true)

    post integrations_telegram_webhooks_path, params: { callback_query: callback_query }

    @donation.reload
    assert_equal "paid", @donation.state
  end

  test "rejects order payment through callback" do
    cache_data = { payable_type: "order", payable_id: @order.order_id, chat_id: "test_chat_id", message_id: 456, caption: "Test order" }

    Rails.cache.stubs(:read).with("pending_rejection:789").returns(cache_data)
    Rails.cache.stubs(:write).returns(true)
    Rails.cache.stubs(:delete).returns(true)

    callback_query = {
      id: "123",
      data: "reject:order:#{@order.order_id}",
      message: { chat: { id: "test_chat_id" }, message_id: 456, caption: "Test order" },
      from: { id: 789 }
    }

    TelegramClient.any_instance.expects(:answer_callback_query).with("123").returns(success: true)
    TelegramClient.any_instance.expects(:send_message_with_reply).with("Please enter rejection reason:").returns(success: true)

    post integrations_telegram_webhooks_path, params: { callback_query: callback_query }

    rejection_message = {
      text: "Insufficient payment",
      from: { id: 789 }
    }

    TelegramClient.any_instance.expects(:edit_message_caption).returns(success: true)
    TelegramClient.any_instance.expects(:edit_message_reply_markup).returns(success: true)
    TelegramClient.any_instance.expects(:send_message).with("✅ Payment rejected successfully!", parse_mode: "Markdown").returns(success: true)

    post integrations_telegram_webhooks_path, params: { message: rejection_message }

    @order.reload
    assert_equal "failed", @order.state
  end

  test "rejects donation payment through callback" do
    cache_data = { payable_type: "donation", payable_id: @donation.donation_id, chat_id: "test_chat_id", message_id: 456, caption: "Test donation" }

    Rails.cache.stubs(:read).with("pending_rejection:789").returns(cache_data)
    Rails.cache.stubs(:write).returns(true)
    Rails.cache.stubs(:delete).returns(true)

    callback_query = {
      id: "123",
      data: "reject:donation:#{@donation.donation_id}",
      message: { chat: { id: "test_chat_id" }, message_id: 456, caption: "Test donation" },
      from: { id: 789 }
    }

    TelegramClient.any_instance.expects(:answer_callback_query).with("123").returns(success: true)
    TelegramClient.any_instance.expects(:send_message_with_reply).with("Please enter rejection reason:").returns(success: true)

    post integrations_telegram_webhooks_path, params: { callback_query: callback_query }

    rejection_message = {
      text: "Invalid donation amount",
      from: { id: 789 }
    }

    TelegramClient.any_instance.expects(:edit_message_caption).returns(success: true)
    TelegramClient.any_instance.expects(:edit_message_reply_markup).returns(success: true)
    TelegramClient.any_instance.expects(:send_message).with("✅ Payment rejected successfully!", parse_mode: "Markdown").returns(success: true)

    post integrations_telegram_webhooks_path, params: { message: rejection_message }

    @donation.reload
    assert_equal "failed", @donation.state
  end

  test "marks evidences as checked after approval" do
    evidence = @order.payment_evidences.create(
      file: File.open(Rails.root.join("test/fixtures/files/test.pdf")),
      checked: false
    )

    callback_query = {
      id: "123",
      data: "approve:order:#{@order.order_id}",
      message: { chat: { id: "test_chat_id" } }
    }

    TelegramClient.any_instance.expects(:answer_callback_query).returns(success: true)

    post integrations_telegram_webhooks_path, params: { callback_query: callback_query }

    evidence.reload
    assert evidence.checked
  end

  test "marks evidences as checked after rejection" do
    cache_data = { payable_type: "order", payable_id: @order.order_id, chat_id: "test_chat_id", message_id: 456, caption: "Test order" }

    Rails.cache.stubs(:read).with("pending_rejection:789").returns(cache_data)
    Rails.cache.stubs(:write).returns(true)
    Rails.cache.stubs(:delete).returns(true)

    evidence = @order.payment_evidences.create(
      file: File.open(Rails.root.join("test/fixtures/files/test.pdf")),
      checked: false
    )

    callback_query = {
      id: "123",
      data: "reject:order:#{@order.order_id}",
      message: { chat: { id: "test_chat_id" }, message_id: 456, caption: "Test order" },
      from: { id: 789 }
    }

    TelegramClient.any_instance.expects(:answer_callback_query).with("123").returns(success: true)
    TelegramClient.any_instance.expects(:send_message_with_reply).with("Please enter rejection reason:").returns(success: true)

    post integrations_telegram_webhooks_path, params: { callback_query: callback_query }

    rejection_message = {
      text: "Test rejection reason",
      from: { id: 789 }
    }

    TelegramClient.any_instance.expects(:edit_message_caption).returns(success: true)
    TelegramClient.any_instance.expects(:edit_message_reply_markup).returns(success: true)
    TelegramClient.any_instance.expects(:send_message).with("✅ Payment rejected successfully!", parse_mode: "Markdown").returns(success: true)

    post integrations_telegram_webhooks_path, params: { message: rejection_message }

    evidence.reload
    assert evidence.checked
  end

  test "handles invalid callback data format" do
    callback_query = {
      id: "123",
      data: "invalid_data",
      message: { chat: { id: "test_chat_id" } }
    }

    TelegramClient.any_instance.expects(:answer_callback_query)
      .with("123", text: "Invalid callback data", show_alert: true)
      .returns(success: true)

    post integrations_telegram_webhooks_path, params: { callback_query: callback_query }
    assert_response :ok
  end

  test "handles unknown action" do
    callback_query = {
      id: "123",
      data: "unknown:order:#{@order.order_id}",
      message: { chat: { id: "test_chat_id" } }
    }

    TelegramClient.any_instance.expects(:answer_callback_query)
      .with("123", text: "Unknown action", show_alert: true)
      .returns(success: true)

    post integrations_telegram_webhooks_path, params: { callback_query: callback_query }
    assert_response :ok
  end

  test "handles non-existent order" do
    callback_query = {
      id: "123",
      data: "approve:order:non-existent-id",
      message: { chat: { id: "test_chat_id" } }
    }

    TelegramClient.any_instance.expects(:answer_callback_query)
      .with("123", text: "Order not found", show_alert: true)
      .returns(success: true)

    post integrations_telegram_webhooks_path, params: { callback_query: callback_query }
    assert_response :ok
  end

  test "handles non-existent donation" do
    callback_query = {
      id: "123",
      data: "approve:donation:non-existent-id",
      message: { chat: { id: "test_chat_id" } }
    }

    TelegramClient.any_instance.expects(:answer_callback_query)
      .with("123", text: "Donation not found", show_alert: true)
      .returns(success: true)

    post integrations_telegram_webhooks_path, params: { callback_query: callback_query }
    assert_response :ok
  end

  test "handles order that is not pending" do
    @order.update(state: "paid")

    callback_query = {
      id: "123",
      data: "approve:order:#{@order.order_id}",
      message: { chat: { id: "test_chat_id" } }
    }

    TelegramClient.any_instance.expects(:answer_callback_query)
      .with("123", text: "Payment is not pending", show_alert: true)
      .returns(success: true)

    post integrations_telegram_webhooks_path, params: { callback_query: callback_query }
    assert_response :ok
  end

  test "handles donation that is not pending" do
    @donation.update(state: "paid")

    callback_query = {
      id: "123",
      data: "approve:donation:#{@donation.donation_id}",
      message: { chat: { id: "test_chat_id" } }
    }

    TelegramClient.any_instance.expects(:answer_callback_query)
      .with("123", text: "Payment is not pending", show_alert: true)
      .returns(success: true)

    post integrations_telegram_webhooks_path, params: { callback_query: callback_query }
    assert_response :ok
  end

  test "responds with ok to regular message" do
    message = {
      message_id: 123,
      text: "Hello",
      chat: { id: "test_chat_id" }
    }

    post integrations_telegram_webhooks_path, params: { message: message }
    assert_response :ok
  end

  test "handles errors gracefully" do
    callback_query = {
      id: "123",
      data: "approve:order:#{@order.order_id}",
      message: { chat: { id: "test_chat_id" } }
    }

    Order.any_instance.stubs(:update!).raises(StandardError.new("Database error"))

    post integrations_telegram_webhooks_path, params: { callback_query: callback_query }
    assert_response :ok
  end

  test "allows webhook without secret token when not configured" do
    callback_query = {
      id: "123",
      data: "approve:order:#{@order.order_id}",
      message: { chat: { id: "test_chat_id" } }
    }

    TelegramClient.any_instance.expects(:answer_callback_query).returns(success: true)

    post integrations_telegram_webhooks_path, params: { callback_query: callback_query }
    assert_response :ok
  end

  test "rejects webhook with invalid secret token" do
    Setting.create(key: "telegram_webhook_secret_token", value: "correct_secret_token")

    callback_query = {
      id: "123",
      data: "approve:order:#{@order.order_id}",
      message: { chat: { id: "test_chat_id" } }
    }

    post integrations_telegram_webhooks_path, params: { callback_query: callback_query },
      headers: { "X-Telegram-Bot-Api-Secret-Token" => "wrong_token" }

    assert_response :unauthorized
  end

  test "rejects webhook without secret token when configured" do
    Setting.create(key: "telegram_webhook_secret_token", value: "correct_secret_token")

    callback_query = {
      id: "123",
      data: "approve:order:#{@order.order_id}",
      message: { chat: { id: "test_chat_id" } }
    }

    post integrations_telegram_webhooks_path, params: { callback_query: callback_query }

    assert_response :unauthorized
  end

  test "allows webhook with valid secret token" do
    Setting.create(key: "telegram_webhook_secret_token", value: "correct_secret_token")

    callback_query = {
      id: "123",
      data: "approve:order:#{@order.order_id}",
      message: { chat: { id: "test_chat_id" } }
    }

    TelegramClient.any_instance.expects(:answer_callback_query).returns(success: true)

    post integrations_telegram_webhooks_path, params: { callback_query: callback_query },
      headers: { "X-Telegram-Bot-Api-Secret-Token" => "correct_secret_token" }

    assert_response :ok
  end

  test "enforces rate limit after exceeding threshold" do
    Rails.cache.clear

    rate_limit_threshold = Integrations::TelegramWebhooksController::RATE_LIMIT
    rate_limit_period = Integrations::TelegramWebhooksController::RATE_LIMIT_PERIOD

    assert rate_limit_threshold > 0, "Rate limit should be positive"
    assert rate_limit_period.present?, "Rate limit period should be set"
    assert rate_limit_threshold.is_a?(Integer), "Rate limit should be an integer"
    assert rate_limit_period.is_a?(ActiveSupport::Duration), "Rate limit period should be a duration"

    assert_equal 30, rate_limit_threshold, "Default rate limit should be 30 requests"
    assert_equal 1.minute, rate_limit_period, "Default rate limit period should be 1 minute"
  end
end
