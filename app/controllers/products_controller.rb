class ProductsController < ApplicationController
  before_action :set_product, only: [ :show ]

  def index
    @products = Product.active.order(id: :desc)
  end

  def show
    @upsells = @product.active_upsells
    @cross_sells = @product.active_cross_sells
  end

  private

  def set_product
    @product = Product.find_by(slug: params[:id])
  end
end
