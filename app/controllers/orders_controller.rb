class OrdersController < ApplicationController
  def create
    begin
      ActiveRecord::Base.transaction do
        @order = Transaction.new(Current.cart).create(checkout_params)
        if @order.invalid?
          redirect_to cart_path, alert: @order.errors.full_messages.first
          return
        end

        if @order.total_price.zero?
          @order.paid!
          redirect_to cart_path
        else
          redirect_url = Transaction::Payment.for(@order).redirect_url
          redirect_to redirect_url, allow_other_host: true
        end
      end
    rescue StandardError => e
      # capture exception to sentry
      message = if Rails.env.production?
        "Error terjadi ketika memproses pesanan kakak. Silahkan coba lagi nanti."
      else
        e.message
      end

      redirect_to cart_path, alert: message
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
        :customer_phone,
        :address_line,
        :shipping_province_id,
        :shipping_city_id,
        :shipping_district_id,
        :shipping_subdistrict_id,
        :order_notes,
        :shipping_cost_id
      )
    end
end
