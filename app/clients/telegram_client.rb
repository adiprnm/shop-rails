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

  def send_photo(photo_path, caption: nil, parse_mode: "Markdown")
    response = post_multipart("/bot#{bot_token}/sendPhoto", {
      chat_id: chat_id,
      photo: File.open(photo_path),
      caption: caption,
      parse_mode: parse_mode
    })

    return response if response[:success]

    Rails.logger.error "Telegram send_photo failed: #{response[:error]}"
    response
  rescue StandardError => e
    Rails.logger.error "Telegram send_photo error: #{e.class} - #{e.message}"
    { success: false, error: e.message }
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

    def post_multipart(url, params)
      uri = URI.parse("#{base_url}#{url}")
      http = setup_http(uri)

      request = Net::HTTP::Post.new(uri)
      request.set_form(params, multipart: true)

      response = http.request(request)
      parse_response(response)
    end

    def parse_response(response)
      result = {
        status: response.code.to_i,
        message: response.message,
        headers: response.to_hash,
        data: nil,
        error: nil
      }

      case response.code.to_i
      when 200..299
        begin
          result[:data] = JSON.parse(response.body).with_indifferent_access
        rescue JSON::ParserError => e
          result[:error] = "Failed to parse JSON response: #{e.message}"
        end
      when 401
        result[:error] = "Unauthorized - Check your credentials"
      when 403
        result[:error] = "Forbidden - You don't have permission to access this resource"
      when 404
        result[:error] = "Not Found - The requested resource doesn't exist"
      when 429
        result[:error] = "Too Many Requests - Rate limit exceeded"
      when 500..599
        result[:error] = "Server Error - Status #{response.code}: #{response.message}"
      else
        result[:error] = "Unexpected Status #{response.code}: #{response.message}"
      end

      result[:success] = result[:error].nil?
      result
    rescue StandardError => e
      {
        success: false,
        status: nil,
        message: "Request Failed",
        headers: {},
        data: nil,
        error: "#{e.class}: #{e.message}"
      }
    end

    def setup_http(uri)
      http = Net::HTTP.new(uri.host, uri.port)
      if uri.scheme == "https"
        http.use_ssl = true
        http.verify_mode = OpenSSL::SSL::VERIFY_PEER
      end

      if Rails.env.development?
        http.set_debug_output($stdout)
      end

      http
    end
end
