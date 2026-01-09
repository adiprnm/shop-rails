class RajaOngkirClient < ApplicationClient
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
    get("/province")
  end

  def get_cities(province_id)
    get("/city", province: province_id)
  end

  def get_districts(city_id)
    get("/subdistrict", city: city_id)
  end

  def get_subdistricts(district_id)
    get("/subdistrict", district: district_id)
  end

  def calculate_cost(origin, destination, weight, courier)
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
