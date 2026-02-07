class CartsController < ApplicationController
  before_action :set_cart, only: %i[show apply_coupon remove_coupon]

  def show
    if params[:order_id].present?
      @payable = Order.find_or_initialize_by(order_id: params[:order_id])
      @payable = Donation.find_or_initialize_by(donation_id: params[:order_id]) if @payable.new_record?
    end

    @cart_recommendations = Product.cart_recommendations(Current.cart)
  end

  def apply_coupon
    coupon_code = params[:coupon_code]&.strip

    if @cart.apply_coupon!(coupon_code, customer_email: session[:customer_email])
      redirect_to cart_path, notice: "Coupon applied successfully"
    else
      redirect_to cart_path, alert: @cart.errors.full_messages.to_sentence
    end
  end

  def remove_coupon
    @cart.remove_coupon!
    redirect_to cart_path, notice: "Coupon removed"
  end

  private

  def set_cart
    @cart = Current.cart
  end
end
