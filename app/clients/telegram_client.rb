class TelegramClient < ApplicationClient
  def send_message(text, parse_mode: "Markdown")
    response = post("/bot#{bot_token}/sendMessage", {
      chat_id: chat_id,
      text: text,
      parse_mode: parse_mode
    })

    return response if response[:success]

    Rails.logger.error "Telegram send_message failed: #{response[:error]}"
    response
  end

  class Error < StandardError; end

  private
    def base_url
      "https://api.telegram.org"
    end

    def bot_token
      Current.settings["telegram_bot_token"]
    end

    def chat_id
      Current.settings["telegram_chat_id"]
    end

    def error?(response)
      response.dig(:data, "ok") == false
    end

    def perform_request(request)
      response = super

      if error?(response)
        error_description = response.dig(:data, "description")
        error_code = response.dig(:data, "error_code")
        response[:error] = "Telegram API Error (#{error_code}): #{error_description}" if error_description
        response[:success] = false
      end

      response
    end
end
