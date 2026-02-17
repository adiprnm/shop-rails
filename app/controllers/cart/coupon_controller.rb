class Cart::CouponController < ApplicationController
  def create
    coupon_code = params[:coupon_code]&.strip

    if Current.cart.apply_coupon!(coupon_code, customer_email: session[:customer_email])
      redirect_to cart_path, notice: "Coupon applied successfully"
    else
      redirect_to cart_path, alert: Current.cart.errors.full_messages.to_sentence
    end
  end

  def destroy
    Current.cart.remove_coupon!
    redirect_to cart_path, notice: "Coupon removed"
  end
end
