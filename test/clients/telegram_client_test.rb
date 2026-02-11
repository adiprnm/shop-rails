require "test_helper"
require "mocha/minitest"

class TelegramClientTest < ActiveSupport::TestCase
  setup do
    Current.settings = {
      "telegram_bot_token" => "test_bot_token",
      "telegram_chat_id" => "test_chat_id"
    }
    @client = TelegramClient.new
  end

  test "responds to send_message" do
    assert_respond_to @client, :send_message
  end

  test "responds to send_photo" do
    assert_respond_to @client, :send_photo
  end

  test "send_message returns success for valid response" do
    response = {
      status: 200,
      data: { "ok" => true, "result" => { "message_id" => 123 } },
      success: true
    }

    @client.expects(:post)
      .with("/bottest_bot_token/sendMessage", {
        chat_id: "test_chat_id",
        text: "Test message",
        parse_mode: "Markdown"
      })
      .returns(response)

    result = @client.send_message("Test message", parse_mode: "Markdown")
    assert result[:success]
  end

  test "send_message handles invalid token error" do
    response = {
      status: 401,
      error: "Unauthorized - Check your credentials",
      success: false
    }

    @client.expects(:post)
      .returns(response)

    result = @client.send_message("Test message")
    assert_not result[:success]
    assert_includes result[:error], "Unauthorized"
  end

  test "send_message handles network errors" do
    @client.expects(:post)
      .raises(Errno::ECONNREFUSED.new("Connection refused"))

    result = @client.send_message("Test message")
    assert_not result[:success]
    assert_includes result[:error], "Connection refused"
  end

  test "send_photo returns success for valid response" do
    response = {
      status: 200,
      data: { "ok" => true, "result" => { "message_id" => 456 } },
      success: true
    }

    file = Tempfile.new(["test", ".jpg"])
    File.expects(:open).with(file.path).returns(stub(close: nil))

    @client.expects(:post_multipart)
      .with("/bottest_bot_token/sendPhoto", {
        chat_id: "test_chat_id",
        photo: kind_of(File),
        caption: "Test caption",
        parse_mode: "Markdown"
      })
      .returns(response)

    result = @client.send_photo(file.path, caption: "Test caption", parse_mode: "Markdown")
    assert result[:success]
    file.close
  end

  test "send_photo handles file not found error" do
    result = @client.send_photo("/nonexistent/path.jpg")
    assert_not result[:success]
  end

  test "send_photo handles Telegram API error" do
    response = {
      status: 400,
      error: "Telegram API Error (400): Bad Request: photo is invalid",
      success: false
    }

    file = Tempfile.new(["test", ".jpg"])
    @client.expects(:post_multipart).returns(response)

    result = @client.send_photo(file.path)
    assert_not result[:success]
    assert_includes result[:error], "photo is invalid"
    file.close
  end

  test "send_photo works without caption" do
    response = {
      status: 200,
      data: { "ok" => true },
      success: true
    }

    file = Tempfile.new(["test", ".jpg"])
    @client.expects(:post_multipart)
      .with("/bottest_bot_token/sendPhoto", {
        chat_id: "test_chat_id",
        photo: kind_of(File),
        caption: nil,
        parse_mode: "Markdown"
      })
      .returns(response)

    result = @client.send_photo(file.path)
    assert result[:success]
    file.close
  end

  test "logs error when send_message fails" do
    response = {
      status: 404,
      error: "Not Found - The requested resource doesn't exist",
      success: false
    }

    @client.expects(:post).returns(response)
    Rails.logger.expects(:error).with("Telegram send_message failed: #{response[:error]}")

    @client.send_message("Test message")
  end

  test "logs error when send_photo fails" do
    response = {
      status: 429,
      error: "Too Many Requests - Rate limit exceeded",
      success: false
    }

    file = Tempfile.new(["test", ".jpg"])
    @client.expects(:post_multipart).returns(response)
    Rails.logger.expects(:error).with("Telegram send_photo failed: #{response[:error]}")

    @client.send_photo(file.path)
    file.close
  end

  test "handles Telegram API error response format" do
    response_data = {
      "ok" => false,
      "error_code" => 401,
      "description" => "Unauthorized"
    }

    @client.expects(:post)
      .returns(status: 200, data: response_data, success: true)

    result = @client.send_message("Test")
    assert_not result[:success]
    assert_includes result[:error], "Unauthorized"
    assert_includes result[:error], "401"
  end
end
