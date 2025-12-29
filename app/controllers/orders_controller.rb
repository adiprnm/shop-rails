class OrdersController < ApplicationController
  def create
    ActiveRecord::Base.transaction do
      @order = Transaction.new(Current.cart).create(checkout_params)
      if @order.invalid?
        redirect_to cart_path, alert: @order.errors.full_messages.first
      end

      if @order.total_price.zero?
        @order.paid!
        redirect_to cart_path(order_id: @order.order_id)
      else
        redirect_url = Transaction::Payment.for(@order).redirect_url
        redirect_to redirect_url, allow_other_host: true
      end
    rescue StandardError => e
      # capture exception to sentry
      message = Rails.env.development?? e.message : "Error terjadi ketika memproses pesanan kakak. Silahkan coba lagi nanti."
      debugger
      raise ActiveRecord::Rollback, message
    end
  end

  def show
    @order = Order.find_by!(order_id: params[:id])
    @order.expired! if @order.expire?
  end

  private
    def checkout_params
      params.permit(
        :customer_name,
        :customer_email_address,
        :customer_agree_to_terms,
        :customer_agree_to_receive_newsletter,
      )
    end
end
