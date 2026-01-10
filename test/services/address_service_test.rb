require "test_helper"

class AddressServiceTest < ActiveSupport::TestCase
  test "find_province returns existing province" do
    province = Province.create(rajaongkir_id: "1", name: "Test Province")
    result = AddressService.find_province(province.id)

    assert_equal province, result
  end

  test "find_province yields and stores new province" do
    new_province = nil
    result = AddressService.find_province(999) { new_province = Province.new(rajaongkir_id: "999", name: "New Province") }

    assert result.persisted?
    assert_equal new_province, result
    assert_equal "New Province", result.name
  end

  test "find_city returns existing city" do
    province = Province.create(rajaongkir_id: "1", name: "Test Province")
    city = City.create(rajaongkir_id: "1", name: "Test City", province: province)
    result = AddressService.find_city(city.id)

    assert_equal city, result
  end

  test "find_city yields and stores new city" do
    province = Province.create(rajaongkir_id: "1", name: "Test Province")
    new_city = nil
    result = AddressService.find_city(999) { new_city = City.new(rajaongkir_id: "999", name: "New City", province: province) }

    assert result.persisted?
    assert_equal new_city, result
    assert_equal "New City", result.name
  end

  test "find_province_by_rajaongkir_id returns existing province" do
    province = Province.create(rajaongkir_id: "JAWA", name: "Jawa")
    result = AddressService.find_province_by_rajaongkir_id("JAWA")

    assert_equal province, result
  end

  test "find_province_by_rajaongkir_id yields and stores new province" do
    new_province = nil
    result = AddressService.find_province_by_rajaongkir_id("BALI") { new_province = Province.new(rajaongkir_id: "BALI", name: "Bali") }

    assert result.persisted?
    assert_equal new_province, result
    assert_equal "Bali", result.name
  end

  test "cities_for_province returns cities for given province" do
    province = Province.create(rajaongkir_id: "1", name: "Test Province")
    city1 = City.create(rajaongkir_id: "1", name: "City 1", province: province)
    city2 = City.create(rajaongkir_id: "2", name: "City 2", province: province)

    result = AddressService.cities_for_province(province.id)

    assert_includes result, city1
    assert_includes result, city2
  end

  test "districts_for_city returns districts for given city" do
    province = Province.create(rajaongkir_id: "1", name: "Test Province")
    city = City.create(rajaongkir_id: "1", name: "Test City", province: province)
    district1 = District.create(rajaongkir_id: "1", name: "District 1", city: city)
    district2 = District.create(rajaongkir_id: "2", name: "District 2", city: city)

    result = AddressService.districts_for_city(city.id)

    assert_includes result, district1
    assert_includes result, district2
  end

  test "subdistricts_for_district returns subdistricts for given district" do
    province = Province.create(rajaongkir_id: "1", name: "Test Province")
    city = City.create(rajaongkir_id: "1", name: "Test City", province: province)
    district = District.create(rajaongkir_id: "1", name: "Test District", city: city)
    subdistrict1 = Subdistrict.create(rajaongkir_id: "1", name: "Subdistrict 1", district: district)
    subdistrict2 = Subdistrict.create(rajaongkir_id: "2", name: "Subdistrict 2", district: district)

    result = AddressService.subdistricts_for_district(district.id)

    assert_includes result, subdistrict1
    assert_includes result, subdistrict2
  end

  test "ensure_provinces returns all provinces when they exist" do
    Province.create(rajaongkir_id: "1", name: "Province 1")
    Province.create(rajaongkir_id: "2", name: "Province 2")

    result = AddressService.ensure_provinces

    assert_equal 2, result.length
  end

  test "ensure_provinces returns existing provinces" do
    province = Province.create(rajaongkir_id: "1", name: "Province 1")

    result = AddressService.ensure_provinces

    assert_equal 1, result.length
    assert_includes result, province
  end

  test "ensure_cities returns cities for given province" do
    province = Province.create(rajaongkir_id: "1", name: "Test Province")
    City.create(rajaongkir_id: "1", name: "City 1", province: province)
    City.create(rajaongkir_id: "2", name: "City 2", province: province)

    result = AddressService.ensure_cities(province.id)

    assert_equal 2, result.length
  end

  test "ensure_cities returns existing cities for given province" do
    province = Province.create(rajaongkir_id: "1", name: "Test Province")
    city = City.create(rajaongkir_id: "1", name: "City 1", province: province)

    result = AddressService.ensure_cities(province.id)

    assert_equal 1, result.length
    assert_includes result, city
  end

  test "ensure_districts returns districts for given city" do
    province = Province.create(rajaongkir_id: "1", name: "Test Province")
    city = City.create(rajaongkir_id: "1", name: "Test City", province: province)
    District.create(rajaongkir_id: "1", name: "District 1", city: city)
    District.create(rajaongkir_id: "2", name: "District 2", city: city)

    result = AddressService.ensure_districts(city.id)

    assert_equal 2, result.length
  end

  test "ensure_districts returns existing districts for given city" do
    province = Province.create(rajaongkir_id: "1", name: "Test Province")
    city = City.create(rajaongkir_id: "1", name: "Test City", province: province)
    district = District.create(rajaongkir_id: "1", name: "District 1", city: city)

    result = AddressService.ensure_districts(city.id)

    assert_equal 1, result.length
    assert_includes result, district
  end

  test "ensure_subdistricts returns subdistricts for given district" do
    province = Province.create(rajaongkir_id: "1", name: "Test Province")
    city = City.create(rajaongkir_id: "1", name: "Test City", province: province)
    district = District.create(rajaongkir_id: "1", name: "Test District", city: city)
    Subdistrict.create(rajaongkir_id: "1", name: "Subdistrict 1", district: district)
    Subdistrict.create(rajaongkir_id: "2", name: "Subdistrict 2", district: district)

    result = AddressService.ensure_subdistricts(district.id)

    assert_equal 2, result.length
  end

  test "ensure_subdistricts returns existing subdistricts for given district" do
    province = Province.create(rajaongkir_id: "1", name: "Test Province")
    city = City.create(rajaongkir_id: "1", name: "Test City", province: province)
    district = District.create(rajaongkir_id: "1", name: "Test District", city: city)
    subdistrict = Subdistrict.create(rajaongkir_id: "1", name: "Subdistrict 1", district: district)

    result = AddressService.ensure_subdistricts(district.id)

    assert_equal 1, result.length
    assert_includes result, subdistrict
  end
end
