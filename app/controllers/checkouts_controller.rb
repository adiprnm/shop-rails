class CheckoutsController < ApplicationController
  def create
    ActiveRecord::Base.transaction do
      order = Transaction.new(Current.cart).create(checkout_params)

      if order.total_price.zero?
        order.paid!
        redirect_to cart_path(order_id: order.order_id)
      else
        begin
          Transaction::Payment.cancel(order.order_id)
        rescue MidtransClient::Error => e
          raise StandardError, e if e.message.exclude?("404")
        ensure
          order.order_id = SecureRandom.uuid
          order.save
        end

        payment = Transaction::Payment.new(order)
        redirect_to payment.payment_url(url: root_url, name: checkout_params[:name]), allow_other_host: true
      end
    rescue StandardError => e
      # capture exception to sentry
      message = Rails.env.development?? e.message : "Error terjadi ketika memproses pesanan kakak. Silahkan coba lagi nanti."
      raise ActiveRecord::Rollback, message
    end
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
