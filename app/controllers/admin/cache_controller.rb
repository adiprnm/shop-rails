class Admin::CacheController < AdminController
  def index
    @cached_addresses = {
      provinces: Province.count,
      cities: City.count,
      districts: District.count,
      subdistricts: Subdistrict.count
    }

    @shipping_cost_cache_count = ShippingCost.count

    @cache_age = calculate_cache_age
  end

  def fetch_provinces
    provinces = AddressService.ensure_provinces
    redirect_to admin_cache_path, notice: "Fetched #{provinces.count} provinces"
  end

  def clear_shipping_cache
    ShippingCost.delete_all
    redirect_to admin_cache_path, notice: "Shipping cost cache cleared"
  end

  private

  def calculate_cache_age
    latest_province = Province.order(created_at: :desc).first
    return nil unless latest_province

    (Time.current - latest_province.created_at).to_i
  end
end
