class Cart::ItemsController < ApplicationController
  def create
    @product = Product.find_by(slug: params[:product_id])

    if @product.coming_soon?
      redirect_to(request.referer.presence || root_url)
    elsif below_minimum_price? && !@product.physical_product?
      redirect_to product_path(@product.slug), alert: "Harga yang kamu masukkan di bawah harga minimal!"
    else
      add_to_cart_logic
    end
  end

  def destroy
    Current.cart.line_items.find(params[:id]).destroy

    redirect_to cart_path
  end

  private

  def add_to_cart_logic
    product_variant = @product.physical_product? ? ProductVariant.find_by(id: params[:product_variant_id]) : nil
    price = determine_price(product_variant)
    quantity = params[:quantity].to_i.positive? ? params[:quantity].to_i : 1

    Current.cart.add_item(@product, price, product_variant, quantity)

    flash[:action] = "add_product_to_cart"
    redirect_to product_path(@product.slug), notice: "Produk berhasil ditambahkan ke keranjang!"
  rescue ArgumentError => e
    redirect_to product_path(@product.slug), alert: e.message
  end

  def determine_price(product_variant)
    if product_variant
      product_variant.price
    elsif params[:price]
      params[:price]
    else
      @product.actual_price
    end
  end

  def below_minimum_price?
    @product.minimum_price.present? && params[:price].to_i < @product.minimum_price
  end
end
