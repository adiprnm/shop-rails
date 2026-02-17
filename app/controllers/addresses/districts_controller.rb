class Addresses::DistrictsController < ApplicationController
  def index
    if params[:city_id].blank?
      render_address_select("shipping_district_select", "Select District")
    else
      districts = AddressService.ensure_districts(params[:city_id])
      render turbo_stream: turbo_stream.update("shipping_district_select", partial: "addresses/districts_options", locals: { districts: districts })
    end
  end

  private

  def render_address_select(target_id, placeholder)
    render turbo_stream: turbo_stream.update(target_id, tag.option(placeholder, value: ""))
  end
end
