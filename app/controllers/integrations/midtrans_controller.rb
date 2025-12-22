class Integrations::MidtransController < ApplicationController
  skip_before_action :verify_authenticity_token
  skip_before_action :set_current_cart

  def payment
    return render json: { "message" => "OK" } if test_payment?
    return render json: { "message" => "Invalid signature" }, status: :unauthorized unless valid_signature?
    return render json: { "message" => "Fraud detected!" }, status: :unauthorized if fraud?

    @payable = Order.find_by(order_id: params[:order_id])
    @payable ||= Donation.find_by(donation_id: params[:order_id])
    return render json: { "message" => "Order/donation not found!" }, status: :not_found unless @payable

    @updated = @payable.update(state: state, integration_data: params.as_json)

    if @updated
      render json: @payable
    else
      render json: { errors: @payable.errors }, status: :unprocessable_entity
    end
  end

  private

  def fraud?
    params[:fraud_status] != "accept"
  end

  def valid_signature?
    required_params = params.permit(:order_id, :status_code, :gross_amount)
    required_params = required_params.as_json.values_at("order_id", "status_code", "gross_amount")
    required_params.push Current.settings["payment_client_secret"]
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
    when "expire" then "expired"
    else "failed"
    end
  end

  def test_payment?
    params[:order_id].to_s.downcase.starts_with?("payment_notif_test")
  end
end
