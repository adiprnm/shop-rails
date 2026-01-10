class Admin::ProductVariantsController < AdminController
  before_action :set_product
  before_action :set_variant, only: %i[ edit update destroy ]

  def index
    @variants = @product.productable.product_variants
  end

  def new
    @variant = @product.productable.product_variants.new
  end

  def create
    @variant = @product.productable.product_variants.new(variant_params)

    if @variant.save
      redirect_to admin_product_variants_path(@product), notice: "Variant created successfully"
    else
      render :new, status: :unprocessable_entity
    end
  end

  def edit
  end

  def update
    if @variant.update(variant_params)
      redirect_to admin_product_variants_path(@product), notice: "Variant updated successfully"
    else
      render :edit, status: :unprocessable_entity
    end
  end

  def destroy
    @variant.destroy
    redirect_to admin_product_variants_path(@product), notice: "Variant deleted successfully"
  end

  def bulk_activate
    @variants = @product.productable.product_variants.where(id: params[:variant_ids])

    @variants.update_all(is_active: true)

    redirect_to admin_product_variants_path(@product), notice: "#{@variants.count} variant(s) activated"
  end

  def bulk_deactivate
    @variants = @product.productable.product_variants.where(id: params[:variant_ids])

    @variants.update_all(is_active: false)

    redirect_to admin_product_variants_path(@product), notice: "#{@variants.count} variant(s) deactivated"
  end

  private

  def set_product
    @product = Product.find(params[:product_id])
  end

  def set_variant
    @variant = @product.productable.product_variants.find(params[:id])
  end

  def variant_params
    params.require(:product_variant).permit(:name, :price, :weight, :stock, :is_active)
  end
end
