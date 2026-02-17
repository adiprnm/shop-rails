class Addresses::ProvincesController < ApplicationController
  def index
    provinces = AddressService.ensure_provinces
    render turbo_stream: turbo_stream.update("provinces-options", partial: "addresses/provinces_options", locals: { provinces: provinces })
  end
end
