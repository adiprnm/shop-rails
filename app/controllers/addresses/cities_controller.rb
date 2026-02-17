class Addresses::CitiesController < ApplicationController
  def index
    if params[:province_id].blank?
      render_address_select("shipping_city_select", "Select City")
    else
      cities = AddressService.ensure_cities(params[:province_id])
      render turbo_stream: turbo_stream.update("shipping_city_select", partial: "addresses/cities_options", locals: { cities: cities })
    end
  end

  private

  def render_address_select(target_id, placeholder)
    render turbo_stream: turbo_stream.update(target_id, tag.option(placeholder, value: ""))
  end
end
