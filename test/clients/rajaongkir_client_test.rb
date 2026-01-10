require "test_helper"

class RajaOngkirClientTest < ActiveSupport::TestCase
  setup do
    @client = RajaOngkirClient.new
  end

  test "responds to get_provinces" do
    assert_respond_to @client, :get_provinces
  end

  test "responds to get_cities" do
    assert_respond_to @client, :get_cities
  end

  test "responds to get_districts" do
    assert_respond_to @client, :get_districts
  end

  test "responds to get_subdistricts" do
    assert_respond_to @client, :get_subdistricts
  end

  test "responds to calculate_cost" do
    assert_respond_to @client, :calculate_cost
  end

  test "has circuit breaker state tracking" do
    client = RajaOngkirClient.new
    assert_respond_to client, :instance_variable_get
  end

  test "has max retries constant" do
    assert_equal 3, RajaOngkirClient::MAX_RETRIES
  end

  test "has circuit breaker threshold constant" do
    assert_equal 5, RajaOngkirClient::CIRCUIT_BREAKER_THRESHOLD
  end

  test "has circuit breaker timeout constant" do
    assert_equal 60, RajaOngkirClient::CIRCUIT_BREAKER_TIMEOUT
  end
end
