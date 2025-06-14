class Admin::DigitalProductsController < ApplicationController
  def new
    @product = DigitalProduct.new
  end
end
