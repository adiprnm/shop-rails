class CartLineItemsController < ApplicationController
  def destroy
    Current.cart.line_items.find(params[:id]).destroy

    redirect_to cart_path
  end
end
