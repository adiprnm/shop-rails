require "test_helper"
require "mocha/minitest"

class Integrations::TelegramWebhooksControllerTest < ActionDispatch::IntegrationTest
  setup do
    @order = orders(:pending_order)
    @donation = donations(:named_donation)
    @donation.update(state: "pending")
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
    callback_query = {
      id: "123",
      data: "reject:order:#{@order.order_id}",
      message: { chat: { id: "test_chat_id" } }
    }

    TelegramClient.any_instance.expects(:answer_callback_query)
      .with("123", text: "Payment rejected", show_alert: false)
      .returns(success: true)

    post integrations_telegram_webhooks_path, params: { callback_query: callback_query }

    @order.reload
    assert_equal "failed", @order.state
  end

  test "rejects donation payment through callback" do
    callback_query = {
      id: "123",
      data: "reject:donation:#{@donation.donation_id}",
      message: { chat: { id: "test_chat_id" } }
    }

    TelegramClient.any_instance.expects(:answer_callback_query)
      .with("123", text: "Payment rejected", show_alert: false)
      .returns(success: true)

    post integrations_telegram_webhooks_path, params: { callback_query: callback_query }

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
    evidence = @order.payment_evidences.create(
      file: File.open(Rails.root.join("test/fixtures/files/test.pdf")),
      checked: false
    )

    callback_query = {
      id: "123",
      data: "reject:order:#{@order.order_id}",
      message: { chat: { id: "test_chat_id" } }
    }

    TelegramClient.any_instance.expects(:answer_callback_query).returns(success: true)

    post integrations_telegram_webhooks_path, params: { callback_query: callback_query }

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
end
