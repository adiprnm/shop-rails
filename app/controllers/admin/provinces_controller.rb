class Admin::ProvincesController < AdminController
  def show
    @province = Province.find(params[:id])
    render plain: options_for_select(@province.cities.map { |c| [ c.name, c.id ] })
  end
end
