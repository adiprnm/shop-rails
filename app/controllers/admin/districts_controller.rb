class Admin::DistrictsController < AdminController
  def show
    @district = District.find(params[:id])
    render plain: options_for_select(@district.subdistricts.map { |s| [ s.name, s.id ] })
  end
end
