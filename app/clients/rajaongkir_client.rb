class RajaOngkirClient < ApplicationClient
  MAX_RETRIES = 3
  BASE_DELAY = 1
  MAX_DELAY = 10
  CIRCUIT_BREAKER_THRESHOLD = 5
  CIRCUIT_BREAKER_TIMEOUT = 60

  def initialize
    super
    @failure_count = 0
    @circuit_open_until = nil
  end

  def base_url
    Setting.rajaongkir_api_host.value
  end

  def default_headers
    { "Key" => Setting.rajaongkir_api_key.value }
  end

  def get_provinces
    retry_with_backoff do
      get("/api/v1/destination/province", {}, default_headers)
    end
  end

  def get_cities(province_id)
    retry_with_backoff do
      get("/api/v1/destination/city/#{province_id}", {}, default_headers)
    end
  end

  def get_districts(city_id)
    retry_with_backoff do
      get("/api/v1/destination/district/#{city_id}", {}, default_headers)
    end
  end

  def get_subdistricts(district_id)
    retry_with_backoff do
      get("/api/v1/destination/sub-district/#{district_id}", {}, default_headers)
    end
  end

  def calculate_cost(origin, destination, weight, courier)
    retry_with_backoff do
      form_data = URI.encode_www_form({
        origin: origin,
        destination: destination,
        weight: weight,
        courier: courier,
        price: "lowest"
      })

      request = Net::HTTP::Post.new("#{base_url}/api/v1/calculate/district/domestic-cost")
      request.body = form_data
      request["Key"] = Setting.rajaongkir_api_key.value
      request["Content-Type"] = "application/x-www-form-urlencoded"
      request["Accept"] = "application/json"

      perform_form_urlencoded_request(request)
    end
  end

  private

  def retry_with_backoff
    check_circuit_breaker

    retries = 0
    begin
      response = yield

      if response[:success]
        reset_circuit_breaker
        return response
      end

      raise "API returned error: #{response[:error]}"
    rescue StandardError => e
      retries += 1
      increment_failure_count

      if retries >= MAX_RETRIES
        Rails.logger.error("RajaOngkir API failed after #{MAX_RETRIES} retries: #{e.message}")
        Rails.logger.error(e.backtrace.join("\n"))
        return { success: false, error: "Service temporarily unavailable" }
      end

      delay = [ BASE_DELAY * (2 ** (retries - 1)), MAX_DELAY ].min
      Rails.logger.warn("RajaOngkir API request failed (#{e.message}), retrying in #{delay}s (attempt #{retries}/#{MAX_RETRIES})")
      sleep(delay)
      retry
    end
  end

  def check_circuit_breaker
    return if @circuit_open_until.nil? || Time.current > @circuit_open_until

    Rails.logger.warn("RajaOngkir API circuit breaker is open until #{@circuit_open_until}")
    raise "Circuit breaker open - API temporarily unavailable"
  end

  def increment_failure_count
    @failure_count += 1
    if @failure_count >= CIRCUIT_BREAKER_THRESHOLD
      @circuit_open_until = Time.current + CIRCUIT_BREAKER_TIMEOUT
      Rails.logger.error("RajaOngkir API circuit breaker opened after #{@failure_count} failures")
    end
  end

  def reset_circuit_breaker
    @failure_count = 0
    @circuit_open_until = nil
  end

  def perform_form_urlencoded_request(request)
    response = http.request(request)
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
end
