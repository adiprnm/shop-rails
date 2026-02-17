class OrdersController < ApplicationController
  def new
    @payable = if params[:order_id].present?
      Order.find_or_initialize_by(order_id: params[:order_id])
    elsif params[:donation_id].present?
      Donation.find_or_initialize_by(donation_id: params[:donation_id])
    end
  end

  def create
    ActiveRecord::Base.transaction do
      @order = Transaction.new(Current.cart).create(checkout_params)

      if @order.invalid?
        redirect_to new_order_path, alert: @order.errors.full_messages.first
      elsif @order.total_price.zero?
        @order.paid!
        redirect_to cart_path
      else
        redirect_to_payment_gateway
      end
    end
  rescue StandardError => e
    redirect_to new_order_path, alert: error_message(e)
  end

  def show
    @order = Order.find_by!(order_id: params[:id])
    @order.expired! if @order.expire?
  end

  private

  def redirect_to_payment_gateway
    redirect_url = Transaction::Payment.for(@order).redirect_url
    redirect_to redirect_url, allow_other_host: trusted_hosts
  end

  def trusted_hosts
    hosts = [ request.host ]

    if Current.settings["payment_provider"] == "midtrans"
      payment_api_host = Current.settings["payment_api_host"]
      hosts << URI.parse(payment_api_host).host if payment_api_host.present?
    end

    hosts
  end

  def error_message(error)
    if Rails.env.production?
      "Error terjadi ketika memproses pesanan kakak. Silahkan coba lagi nanti."
    else
      error.message
    end
  end

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
