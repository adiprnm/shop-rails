class AddressesController < ApplicationController
  def cities
    province_id = params[:province_id]

    if province_id.blank?
      render turbo_stream: turbo_stream.update("cities-options", "")
      return
    end

    cities = AddressService.ensure_cities(province_id)

    render turbo_stream: turbo_stream.update("cities-options", partial: "addresses/cities_options", locals: { cities: cities })
  end

  def districts
    city_id = params[:city_id]

    if city_id.blank?
      render turbo_stream: turbo_stream.update("districts-options", "")
      return
    end

    districts = AddressService.ensure_districts(city_id)

    render turbo_stream: turbo_stream.update("districts-options", partial: "addresses/districts_options", locals: { districts: districts })
  end

  def subdistricts
    district_id = params[:district_id]

    if district_id.blank?
      render turbo_stream: turbo_stream.update("subdistricts-options", "")
      return
    end

    subdistricts = AddressService.ensure_subdistricts(district_id)

    render turbo_stream: turbo_stream.update("subdistricts-options", partial: "addresses/subdistricts_options", locals: { subdistricts: subdistricts })
  end

  def provinces
    provinces = AddressService.ensure_provinces

    render turbo_stream: turbo_stream.update("provinces-options", partial: "addresses/provinces_options", locals: { provinces: provinces })
  end
end
