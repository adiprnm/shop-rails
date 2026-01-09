class AddressService
  CACHE_TTL = 7.days

  def self.find_province(id)
    Province.find_by(id: id) || yield&.tap { |province| province&.save }
  end

  def self.find_city(id)
    City.find_by(id: id) || yield&.tap { |city| city&.save }
  end

  def self.find_district(id)
    District.find_by(id: id) || yield&.tap { |district| district&.save }
  end

  def self.find_subdistrict(id)
    Subdistrict.find_by(id: id) || yield&.tap { |subdistrict| subdistrict&.save }
  end

  def self.find_province_by_rajaongkir_id(rajaongkir_id)
    Province.find_by_rajaongkir_id(rajaongkir_id) || yield&.tap { |province| province&.save }
  end

  def self.find_city_by_rajaongkir_id(rajaongkir_id)
    City.find_by_rajaongkir_id(rajaongkir_id) || yield&.tap { |city| city&.save }
  end

  def self.find_district_by_rajaongkir_id(rajaongkir_id)
    District.find_by_rajaongkir_id(rajaongkir_id) || yield&.tap { |district| district&.save }
  end

  def self.find_subdistrict_by_rajaongkir_id(rajaongkir_id)
    Subdistrict.find_by_rajaongkir_id(rajaongkir_id) || yield&.tap { |subdistrict| subdistrict&.save }
  end

  def self.cities_for_province(province_id)
    City.where(province_id: province_id)
  end

  def self.districts_for_city(city_id)
    District.where(city_id: city_id)
  end

  def self.subdistricts_for_district(district_id)
    Subdistrict.where(district_id: district_id)
  end
end
