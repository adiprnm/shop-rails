class CartsController < ApplicationController
  def show
    if params[:order_id].present?
      @order = Order.find_or_initialize_by(order_id: params[:order_id])
      @show_message = @order.paid?
    end
  end
end
