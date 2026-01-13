class AddressService
  CACHE_TTL = 7.days

  def self.ensure_provinces
    return Province.all if Province.exists?

    client = RajaOngkirClient.new
    response = client.get_provinces

    return Province.all unless response[:success] && response[:data]

    provinces_data = response[:data]["data"] || []

    ActiveRecord::Base.transaction do
      provinces_data.each do |province_data|
        Province.find_or_create_by(rajaongkir_id: province_data["id"]) do |province|
          province.name = province_data["name"]
        end
      end
    end

    Province.all
  end

  def self.ensure_cities(province_id)
    province = Province.find(province_id)
    existing_cities = province.cities

    return existing_cities if existing_cities.exists?

    client = RajaOngkirClient.new
    response = client.get_cities(province.rajaongkir_id)

    return existing_cities unless response[:success] && response[:data]

    cities_data = response[:data]["data"] || []

    ActiveRecord::Base.transaction do
      cities_data.each do |city_data|
        city = province.cities.find_or_create_by(rajaongkir_id: city_data["id"]) do |c|
          c.name = city_data["name"]
          c.zip_code = city_data["zip_code"] if city_data["zip_code"].present?
        end
        city.update(zip_code: city_data["zip_code"]) if city && city_data["zip_code"].present?
      end
    end

    province.cities.reload
  end

  def self.ensure_districts(city_id)
    city = City.find(city_id)
    existing_districts = city.districts

    return existing_districts if existing_districts.exists?

    client = RajaOngkirClient.new
    response = client.get_districts(city.rajaongkir_id)

    return existing_districts unless response[:success] && response[:data]

    districts_data = response[:data]["data"] || []

    ActiveRecord::Base.transaction do
      districts_data.each do |district_data|
        district = city.districts.find_or_create_by(rajaongkir_id: district_data["id"]) do |d|
          d.name = district_data["name"]
          d.zip_code = district_data["zip_code"] if district_data["zip_code"].present?
        end
        district.update(zip_code: district_data["zip_code"]) if district && district_data["zip_code"].present?
      end
    end

    city.districts.reload
  end

  def self.ensure_subdistricts(district_id)
    district = District.find(district_id)
    existing_subdistricts = district.subdistricts

    return existing_subdistricts if existing_subdistricts.exists?

    client = RajaOngkirClient.new
    response = client.get_subdistricts(district.rajaongkir_id)

    return existing_subdistricts unless response[:success] && response[:data]

    subdistricts_data = response[:data]["data"] || []

    ActiveRecord::Base.transaction do
      subdistricts_data.each do |subdistrict_data|
        subdistrict = district.subdistricts.find_or_create_by(rajaongkir_id: subdistrict_data["id"]) do |s|
          s.name = subdistrict_data["name"]
          s.zip_code = subdistrict_data["zip_code"] if subdistrict_data["zip_code"].present?
        end
        subdistrict.update(zip_code: subdistrict_data["zip_code"]) if subdistrict && subdistrict_data["zip_code"].present?
      end
    end

    district.subdistricts.reload
  end

  def self.find_province(id)
    Province.find_by(id: id) || (block_given? ? yield.tap { |province| province&.save } : nil)
  end

  def self.find_city(id)
    City.find_by(id: id) || (block_given? ? yield.tap { |city| city&.save } : nil)
  end

  def self.find_district(id)
    District.find_by(id: id) || (block_given? ? yield.tap { |district| district&.save } : nil)
  end

  def self.find_subdistrict(id)
    Subdistrict.find_by(id: id) || (block_given? ? yield.tap { |subdistrict| subdistrict&.save } : nil)
  end

  def self.find_province_by_rajaongkir_id(rajaongkir_id)
    Province.find_by_rajaongkir_id(rajaongkir_id) || (block_given? ? yield.tap { |province| province&.save } : nil)
  end

  def self.find_city_by_rajaongkir_id(rajaongkir_id)
    City.find_by_rajaongkir_id(rajaongkir_id) || (block_given? ? yield.tap { |city| city&.save } : nil)
  end

  def self.find_district_by_rajaongkir_id(rajaongkir_id)
    District.find_by_rajaongkir_id(rajaongkir_id) || (block_given? ? yield.tap { |district| district&.save } : nil)
  end

  def self.find_subdistrict_by_rajaongkir_id(rajaongkir_id)
    Subdistrict.find_by_rajaongkir_id(rajaongkir_id) || (block_given? ? yield.tap { |subdistrict| subdistrict&.save } : nil)
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
