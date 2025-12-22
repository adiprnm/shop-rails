class ProductsController < ApplicationController
  before_action :set_product, only: %w[ show add_to_cart ]

  def index
    @products = Product.active.order(id: :desc)
  end

  def show
  end

  def add_to_cart
    return redirect_to(request.referer.presence || root_url) if @product.coming_soon?
    return redirect_to product_path(@product.slug), alert: "Harga yang kamu masukkan di bawah harga minimal!" if below_minimum_price?

    Current.cart.add_item(@product, params[:price])

    flash[:action] = "add_product_to_cart"
    redirect_to product_path(@product.slug), notice: "Produk berhasil ditambahkan ke keranjang!"
  end

  private
    def set_product
      @product = Product.find_by slug: params[:id]
    end

    def below_minimum_price?
      @product.minimum_price.present? && params[:price].to_i < @product.minimum_price
    end
end
