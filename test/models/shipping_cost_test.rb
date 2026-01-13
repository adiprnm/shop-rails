require "test_helper"

class ShippingCostTest < ActiveSupport::TestCase
  test "validates origin_type presence" do
    shipping_cost = ShippingCost.new(
      origin_id: 1,
      destination_type: "City",
      destination_id: 1,
      weight: 1000,
      courier: "jne",
      service: "YES",
      cost: 10000
    )
    assert_not shipping_cost.valid?
    assert_includes shipping_cost.errors[:origin_type], "can't be blank"
  end

  test "validates cost numericality" do
    shipping_cost = ShippingCost.new(
      origin_type: "Province",
      origin_id: 1,
      destination_type: "City",
      destination_id: 1,
      weight: 1000,
      courier: "jne",
      service: "YES",
      cost: -1
    )
    assert_not shipping_cost.valid?
    assert_includes shipping_cost.errors[:cost], "must be greater than or equal to 0"
  end

  test "fresh scope returns records created within CACHE_TTL" do
    fresh = shipping_costs(:jne_yes)
    fresh_shipping_costs = ShippingCost.fresh

    assert_includes fresh_shipping_costs, fresh
  end

  test "expired scope returns records older than CACHE_TTL" do
    expired = shipping_costs(:jne_reg_expired)
    expired_shipping_costs = ShippingCost.expired

    assert_includes expired_shipping_costs, expired
  end

  test "find_or_fetch returns fresh record if exists" do
    existing = shipping_costs(:jne_yes)
    result = ShippingCost.find_or_fetch(
      provinces(:jawa_barat),
      cities(:jakarta_barat),
      existing.weight,
      existing.courier,
      existing.service
    ) { ShippingCost.new(
      origin_type: "Province",
      origin_id: 1,
      destination_type: "City",
      destination_id: 1,
      weight: 1000,
      courier: "jne",
      service: "YES",
      cost: 10000
    ) }

    assert_equal existing, result
  end

  test "calculate returns cost" do
    shipping_cost = shipping_costs(:jne_yes)
    assert_equal shipping_cost.cost, shipping_cost.calculate
  end

  test "purge_expired deletes old records" do
    expired_count = ShippingCost.expired.count
    assert_difference -> { ShippingCost.expired.count }, -expired_count do
      ShippingCost.purge_expired
    end
  end

  test "clear_for_destination deletes records for specific destination" do
    city = cities(:jakarta_barat)
    records_count = ShippingCost.where(destination_type: "City", destination_id: city.id).count

    assert_difference -> { ShippingCost.where(destination_type: "City", destination_id: city.id).count }, -records_count do
      ShippingCost.clear_for_destination(city)
    end
  end
end
