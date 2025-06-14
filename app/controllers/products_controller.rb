class ProductsController < ApplicationController
  def index
    @products = Product.active.order(id: :desc)
  end
end
