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
    Setting.rajaongkir_api_host
  end

  def default_headers
    {
      "Content-Type" => "application/json",
      "Accept" => "application/json",
      "Authorization" => "Bearer #{Setting.rajaongkir_api_key}"
    }
  end

  def get_provinces
    retry_with_backoff do
      get("/province")
    end
  end

  def get_cities(province_id)
    retry_with_backoff do
      get("/city", province: province_id)
    end
  end

  def get_districts(city_id)
    retry_with_backoff do
      get("/subdistrict", city: city_id)
    end
  end

  def get_subdistricts(district_id)
    retry_with_backoff do
      get("/subdistrict", district: district_id)
    end
  end

  def calculate_cost(origin, destination, weight, courier)
    retry_with_backoff do
      origin_province = origin.is_a?(Province) ? origin : Province.find(origin)
      origin_city = destination.is_a?(City) ? destination : City.find(destination)
      origin_type = "province"
      origin_id = origin_province.id
      destination_type = "city"
      destination_id = origin_city.id

      post("/cost", {
        origin: origin_type,
        originType: origin_type,
        origin_id: origin_id,
        destination_type: destination_type,
        destinationType: destination_type,
        destination_id: destination_id,
        weight: weight,
        courier: courier
      })
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
end
