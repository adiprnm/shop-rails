require "test_helper"

class ProvinceTest < ActiveSupport::TestCase
  test "has many cities" do
    province = provinces(:one)
    assert_respond_to province, :cities
  end

  test "validates rajaongkir_id presence" do
    province = Province.new(name: "Jawa Barat")
    assert_not province.valid?
    assert_includes province.errors[:rajaongkir_id], "can't be blank"
  end

  test "validates rajaongkir_id uniqueness" do
    existing = provinces(:one)
    province = Province.new(rajaongkir_id: existing.rajaongkir_id, name: "Jawa Tengah")
    assert_not province.valid?
    assert_includes province.errors[:rajaongkir_id], "has already been taken"
  end

  test "validates name presence" do
    province = Province.new(rajaongkir_id: 1)
    assert_not province.valid?
    assert_includes province.errors[:name], "can't be blank"
  end

  test "find_by_rajaongkir_id class method" do
    assert_respond_to Province, :find_by_rajaongkir_id
  end
end
