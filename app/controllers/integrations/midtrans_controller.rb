class Integrations::MidtransController < ApplicationController
  skip_before_action :verify_authenticity_token
  skip_before_action :set_current_cart

  def payment
    return render json: { "message" => "Fraud detected!" }, status: :unauthorized if fraud?
    return render json: { "message" => "Invalid signature" }, status: :unauthorized unless valid_signature?

    @order = Order.find_by!(order_id: params[:order_id])
    @updated = @order.update(state: state, integration_data: params.as_json)

    if @updated
      render json: @subscription
    else
      render json: { errors: @subscription.errors }, status: :unprocessable_entity
    end
  rescue ActiveRecord::RecordNotFound
    render json: { "message" => "Order tidak ditemukan" }, status: :not_found
  end

  private

  def fraud?
    params[:fraud_status] != "accept"
  end

  def valid_signature?
    required_params = params.permit(:order_id, :status_code, :gross_amount)
    required_params = required_params.as_json.values_at("order_id", "status_code", "gross_amount")
    required_params.push Rails.application.credentials.dig(:midtrans, :server_key)
    payload = format("%s%s%s%s", *required_params)

    digest = Digest::SHA2.new(512).hexdigest(payload)
    digest == params[:signature_key]
  end

  def state
    case params[:transaction_status]
    when "capture", "settlement" then "paid"
    when "pending", "authorize" then "pending"
    when "deny", "failure" then "failed"
    when "cancel" then "pending"
    when "expire" then "pending"
    else "failed"
    end
  end
end
