require "net/http"

class ApplicationClient
  def post(url, params, headers = {})
    request = Net::HTTP::Post.new(url)
    request.body = params.to_json

    set_default_headers(request)
    set_custom_headers(request, headers)
    perform_request(request)
  end

  def get(url, params = {}, headers = {})
    encoded_params = URI.encode_www_form(params)
    url = url + "?#{encoded_params}" if encoded_params.present?
    request = Net::HTTP::Get.new(url)

    set_default_headers(request)
    set_custom_headers(request, headers)
    perform_request(request)
  end

  private
    def perform_request(request)
      response = http.request(request)
      result = {
        status: response.code.to_i,
        message: response.message,
        headers: response.to_hash,
        data: nil,
        error: nil
      }
      case response.code.to_i
      when 200..299  # Success
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

    def http
      uri = URI.parse(base_url)
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

    def set_default_headers(request)
      request["Content-Type"] = "application/json"
      request["Accept"] = "application/json"
    end

    def set_custom_headers(request, headers)
      headers.each do |key, value|
        request[key] = value
      end
    end

    def base_url
      raise "Implemented by subclass"
    end
end
