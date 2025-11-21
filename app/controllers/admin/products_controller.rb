class Admin::ProductsController < AdminController
  before_action :set_product, only: %i[ edit update destroy ]

  def index
    @products = Product.order(id: :desc)
  end

  def new
    @product = Product.new
  end

  def create
    @product = Product.create_with_productable(product_params, productable_params)
    redirect_to admin_products_path
  end

  def edit
  end

  def update
    @product.update(product_params)
    @product.productable.update(productable_params)

    redirect_to edit_admin_product_path(@product), notice: "Update berhasil!"
  end

  def destroy
    @product.productable.destroy

    redirect_to admin_products_path, notice: "Produk berhasil dihapus!"
  end

  private
    def product_params
      params.require(:product).permit(
        :name, :slug, :short_description, :description,
        :price, :sale_price, :sale_price_starts_at, :sale_price_ends_at, :minimum_price,
        :productable_type, :featured_image, category_ids: [],
      )
    end

    def productable_params
      case params[:product][:productable_type]
      when "DigitalProduct"
        params.require(:product).require(:productable).permit(
          :resource_type, :resource_url, :resource, :sample
        )
      end
    end

    def set_product
      @product = Product.find(params[:id])
    end
end
