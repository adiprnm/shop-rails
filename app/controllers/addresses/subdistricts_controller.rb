class Addresses::SubdistrictsController < ApplicationController
  def index
    if params[:district_id].blank?
      render_address_select("shipping_subdistrict_select", "Select Subdistrict")
    else
      subdistricts = AddressService.ensure_subdistricts(params[:district_id])
      render turbo_stream: turbo_stream.update("shipping_subdistrict_select", partial: "addresses/subdistricts_options", locals: { subdistricts: subdistricts })
    end
  end

  private

  def render_address_select(target_id, placeholder)
    render turbo_stream: turbo_stream.update(target_id, tag.option(placeholder, value: ""))
  end
end
