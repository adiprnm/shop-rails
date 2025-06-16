class MidtransClient < ApplicationClient
  attr_reader :type

  def initialize(type = "api")
    @type = type
  end

  def snap_redirect_url(params)
    response = post("/snap/v1/transactions", params, headers)
    ensure_successful(response)

    response[:data][:redirect_url]
  end

  def cancel(order_id)
    response = post("/v2/#{order_id}/cancel", {}, headers)
    ensure_successful(response)

    response
  end

  class Error < StandardError; end

  private
    def base_url
      url = Current.settings["payment_api_host"]
      url = url.gsub(/api/, "app") if type == "snap"
      url
    end

    def headers
      { "Authorization" => "Basic #{auth_token}" }
    end

    def auth_token
      Base64.strict_encode64("#{ Current.settings["payment_client_secret"] }:")
    end

    def error?(response)
      status_code = response.dig(:data, :status_code)
      status_code.present? && !status_code.starts_with?("2")
    end

    def ensure_successful(response)
      raise Error, response[:message] unless response[:success]
      return unless error?(response)

      status_code = response.dig(:data, :status_code)
      status_message = response.dig(:data, :status_message)
      raise Error, "#{status_code}: #{status_message}"
    end
end
