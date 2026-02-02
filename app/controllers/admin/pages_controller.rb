class Admin::PagesController < AdminController
  before_action :set_page, only: %w[ edit update destroy ]

  def index
    @pages = Page.all.order(id: :desc)
  end

  def new
    @page = Page.new
  end

  def create
    @page = Page.create(page_params)

    redirect_to edit_admin_page_path(@page), notice: "Laman berhasil dibuat"
  end

  def edit
  end

  def update
    @page.update page_params

    redirect_to edit_admin_page_path(@page), notice: "Laman berhasil diupdate"
  end

  def destroy
    @page.destroy

    redirect_to admin_pages_path, notice: "Laman berhasil dihapus"
  end

  private
    def page_params
      params.require(:page).permit(:title, :slug, :description, :content, :state)
    end

    def set_page
      @page = Page.find params[:id]
    end
end
