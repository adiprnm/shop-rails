class Admin::CitiesController < AdminController
  def show
    @city = City.find(params[:id])
    render plain: options_for_select(@city.districts.map { |d| [ d.name, d.id ] })
  end
end
