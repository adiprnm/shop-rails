namespace :addresses do
  desc "Fetch and store all provinces from RajaOngkir API"
  task fetch_provinces: :environment do
    puts "Fetching provinces from RajaOngkir API..."
    client = RajaOngkirClient.new
    response = client.get_provinces

    unless response[:success]
      puts "Error fetching provinces: #{response[:error]}"
      return
    end

    provinces_data = response[:data]["data"] || []
    puts "Found #{provinces_data.length} provinces"

    count = 0
    ActiveRecord::Base.transaction do
      provinces_data.each do |province_data|
        province = Province.find_or_create_by(rajaongkir_id: province_data["id"]) do |p|
          p.name = province_data["name"]
        end
        count += 1 if province
      end
    end

    puts "Successfully fetched and stored #{count} provinces"
  end

  desc "Clear and re-fetch all addresses (for initial setup)"
  task reset: :environment do
    puts "Clearing existing address data..."
    Subdistrict.delete_all
    District.delete_all
    City.delete_all
    Province.delete_all
    puts "Address data cleared"

    puts "Fetching provinces..."
    Rake::Task["addresses:fetch_provinces"].invoke
  end

  desc "Fetch and store cities for all provinces"
  task fetch_cities: :environment do
    puts "Fetching cities for all provinces..."
    provinces = Province.all
    total_cities = 0

    provinces.each do |province|
      puts "Fetching cities for #{province.name}..."
      client = RajaOngkirClient.new
      response = client.get_cities(province.rajaongkir_id)

      unless response[:success]
        puts "  Error fetching cities: #{response[:error]}"
        next
      end

      cities_data = response[:data]["data"] || []
      puts "  Found #{cities_data.length} cities"

      count = 0
      ActiveRecord::Base.transaction do
        cities_data.each do |city_data|
          city = province.cities.find_or_create_by(rajaongkir_id: city_data["id"]) do |c|
            c.name = city_data["name"]
            c.zip_code = city_data["zip_code"] if city_data["zip_code"].present?
          end
          city.update(zip_code: city_data["zip_code"]) if city && city_data["zip_code"].present?
          count += 1 if city
        end
      end

      total_cities += count
      puts "  Stored #{count} cities"
    end

    puts "Successfully fetched and stored #{total_cities} cities"
  end

  desc "Fetch and store districts for all cities"
  task fetch_districts: :environment do
    puts "Fetching districts for all cities..."
    cities = City.all
    total_districts = 0

    cities.each do |city|
      puts "Fetching districts for #{city.name}..."
      client = RajaOngkirClient.new
      response = client.get_districts(city.rajaongkir_id)

      unless response[:success]
        puts "  Error fetching districts: #{response[:error]}"
        next
      end

      districts_data = response[:data]["data"] || []
      puts "  Found #{districts_data.length} districts"

      count = 0
      ActiveRecord::Base.transaction do
        districts_data.each do |district_data|
          district = city.districts.find_or_create_by(rajaongkir_id: district_data["id"]) do |d|
            d.name = district_data["name"]
            d.zip_code = district_data["zip_code"] if district_data["zip_code"].present?
          end
          district.update(zip_code: district_data["zip_code"]) if district && district_data["zip_code"].present?
          count += 1 if district
        end
      end

      total_districts += count
      puts "  Stored #{count} districts"
    end

    puts "Successfully fetched and stored #{total_districts} districts"
  end

  desc "Fetch and store subdistricts for all districts"
  task fetch_subdistricts: :environment do
    puts "Fetching subdistricts for all districts..."
    districts = District.all
    total_subdistricts = 0

    districts.each do |district|
      puts "Fetching subdistricts for #{district.name}..."
      client = RajaOngkirClient.new
      response = client.get_subdistricts(district.rajaongkir_id)

      unless response[:success]
        puts "  Error fetching subdistricts: #{response[:error]}"
        next
      end

      subdistricts_data = response[:data]["data"] || []
      puts "  Found #{subdistricts_data.length} subdistricts"

      count = 0
      ActiveRecord::Base.transaction do
        subdistricts_data.each do |subdistrict_data|
          subdistrict = district.subdistricts.find_or_create_by(rajaongkir_id: subdistrict_data["id"]) do |s|
            s.name = subdistrict_data["name"]
            s.zip_code = subdistrict_data["zip_code"] if subdistrict_data["zip_code"].present?
          end
          subdistrict.update(zip_code: subdistrict_data["zip_code"]) if subdistrict && subdistrict_data["zip_code"].present?
          count += 1 if subdistrict
        end
      end

      total_subdistricts += count
      puts "  Stored #{count} subdistricts"
    end

    puts "Successfully fetched and stored #{total_subdistricts} subdistricts"
  end

  desc "Fetch all address data (provinces, cities, districts, subdistricts)"
  task fetch_all: :environment do
    puts "Fetching all address data from RajaOngkir API..."

    puts "=" * 60
    Rake::Task["addresses:fetch_provinces"].invoke
    puts "=" * 60

    puts "=" * 60
    Rake::Task["addresses:fetch_cities"].invoke
    puts "=" * 60

    puts "=" * 60
    Rake::Task["addresses:fetch_districts"].invoke
    puts "=" * 60

    puts "=" * 60
    Rake::Task["addresses:fetch_subdistricts"].invoke
    puts "=" * 60

    puts "All address data fetched successfully!"
    puts "Provinces: #{Province.count}"
    puts "Cities: #{City.count}"
    puts "Districts: #{District.count}"
    puts "Subdistricts: #{Subdistrict.count}"
  end
end
