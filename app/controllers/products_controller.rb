class ProductsController < ApplicationController
  before_action :set_product, only: %w[ show add_to_cart ]

  def index
    @products = Product.active.order(id: :desc)
  end

  def show
  end

  def add_to_cart
    return redirect_to(request.referer.presence || root_url) if @product.coming_soon?

    Current.cart.add_item(@product)

    flash[:action] = "add_product_to_cart"
    redirect_to product_path(@product.slug), notice: "Produk berhasil ditambahkan ke keranjang!"
  end

  private
    def set_product
      @product = Product.find_by slug: params[:id]
    end
end
