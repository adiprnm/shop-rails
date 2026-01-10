class ProductsController < ApplicationController
  before_action :set_product, only: %w[ show add_to_cart ]

  def index
    @products = Product.active.order(id: :desc)
  end

  def show
  end

  def add_to_cart
    return redirect_to(request.referer.presence || root_url) if @product.coming_soon?
    return redirect_to product_path(@product.slug), alert: "Harga yang kamu masukkan di bawah harga minimal!" if below_minimum_price? && !@product.physical_product?

    product_variant = @product.physical_product? ? ProductVariant.find_by(id: params[:product_variant_id]) : nil
    price = if product_variant
              product_variant.price
    elsif params[:price]
              params[:price]
    else
              @product.actual_price
    end

    Current.cart.add_item(@product, price, product_variant)

    flash[:action] = "add_product_to_cart"
    redirect_to product_path(@product.slug), notice: "Produk berhasil ditambahkan ke keranjang!"
  rescue ArgumentError => e
    redirect_to product_path(@product.slug), alert: e.message
  end

  private
    def set_product
      @product = Product.find_by slug: params[:id]
    end

    def below_minimum_price?
      @product.minimum_price.present? && params[:price].to_i < @product.minimum_price
    end
end
