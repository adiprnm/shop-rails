class AddressesController < ApplicationController
  def cities
    if params[:province_id].blank?
      render_address_select("shipping_city_select", "Select City")
    else
      cities = AddressService.ensure_cities(params[:province_id])
      render turbo_stream: turbo_stream.update("shipping_city_select", partial: "addresses/cities_options", locals: { cities: cities })
    end
  end

  def districts
    if params[:city_id].blank?
      render_address_select("shipping_district_select", "Select District")
    else
      districts = AddressService.ensure_districts(params[:city_id])
      render turbo_stream: turbo_stream.update("shipping_district_select", partial: "addresses/districts_options", locals: { districts: districts })
    end
  end

  def subdistricts
    if params[:district_id].blank?
      render_address_select("shipping_subdistrict_select", "Select Subdistrict")
    else
      subdistricts = AddressService.ensure_subdistricts(params[:district_id])
      render turbo_stream: turbo_stream.update("shipping_subdistrict_select", partial: "addresses/subdistricts_options", locals: { subdistricts: subdistricts })
    end
  end

  def provinces
    provinces = AddressService.ensure_provinces
    render turbo_stream: turbo_stream.update("provinces-options", partial: "addresses/provinces_options", locals: { provinces: provinces })
  end

  private

  def render_address_select(target_id, placeholder)
    render turbo_stream: turbo_stream.update(target_id, tag.option(placeholder, value: ""))
  end
end
