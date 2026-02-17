class CartsController < ApplicationController
  def show
    if params[:order_id].present?
      @payable = Order.find_or_initialize_by(order_id: params[:order_id])
      @payable = Donation.find_or_initialize_by(donation_id: params[:order_id]) if @payable.new_record?
    end

    @cart_recommendations = Product.cart_recommendations(Current.cart)
  end
end
