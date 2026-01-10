class Admin::ProductsController < AdminController
  before_action :set_product, only: %i[ show edit update destroy ]

  def index
    @products = Product.order(id: :desc)

    if params[:product_type].present?
      @products = @products.where(productable_type: params[:product_type])
    end

    if params[:sort_by] == "stock"
      @products = @products.includes(:productable).sort_by { |p| p.physical? ? p.productable.product_variants.sum(:stock) : 0 }
    end
  end

  def new
    @product = Product.new
  end

  def create
    @product = Product.create_with_productable(product_params, productable_params || {})

    redirect_to admin_products_path
  end

  def show
  end

  def edit
  end

  def update
    @product.update(product_params)

    if productable_params
      @product.productable.update(productable_params)
    end

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
      product_variants_attributes: [ :id, :name, :price, :weight, :stock, :is_active, :_destroy ]
    )
  end

  def productable_params
    productable_type = params[:product][:productable_type] || @product.productable_type
    productable = params[:product][:productable]

    if productable_type == "DigitalProduct" && productable
      productable.permit(:resource_type, :resource_url, :resource, :sample)
    elsif productable_type == "PhysicalProduct" && productable
      productable.permit(:weight, :requires_shipping)
    end
  end

  def set_product
    @product = Product.find(params[:id])
  end
end
