class Admin::CategoriesController < AdminController
  before_action :set_category, only: %w[ edit update destroy ]

  def index
    @categories = Category.order(id: :desc)
  end

  def create
    @category = Category.create(category_params)

    redirect_to admin_categories_path, notice: "Kategori berhasil dibuat!"
  end

  def edit; end

  def update
    @category.update(category_params)

    redirect_to admin_category_path(@category), notice: "Kategori berhasil diupdate!"
  end

  def destroy
    @category.destroy

    redirect_to admin_categories_path, notice: "Kategori berhasil dihapus!"
  end

  private
    def category_params
      params.require(:category).permit(:name, :slug)
    end

    def set_category
      @category = Category.find(params[:id])
    end
end
