require "test_helper"

class CityTest < ActiveSupport::TestCase
  test "belongs to province" do
    city = cities(:one)
    assert_respond_to city, :province
  end

  test "has many districts" do
    city = cities(:one)
    assert_respond_to city, :districts
  end

  test "validates rajaongkir_id presence" do
    city = City.new(name: "Jakarta Barat", province: provinces(:one))
    assert_not city.valid?
    assert_includes city.errors[:rajaongkir_id], "can't be blank"
  end

  test "validates rajaongkir_id uniqueness" do
    existing = cities(:one)
    city = City.new(rajaongkir_id: existing.rajaongkir_id, name: "Jakarta Timur", province: provinces(:one))
    assert_not city.valid?
    assert_includes city.errors[:rajaongkir_id], "has already been taken"
  end

  test "validates name presence" do
    city = City.new(rajaongkir_id: 1, province: provinces(:one))
    assert_not city.valid?
    assert_includes city.errors[:name], "can't be blank"
  end

  test "find_by_rajaongkir_id class method" do
    assert_respond_to City, :find_by_rajaongkir_id
  end
end
