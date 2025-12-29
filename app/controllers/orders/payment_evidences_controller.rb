class Orders::PaymentEvidencesController < ApplicationController
  def new
    @order = Order.find_by!(order_id: params[:order_id])
    @payment_evidence = OrderPaymentEvidence.new
  end

  def create
    @order = Order.find_by!(order_id: params[:order_id])
    @order.payment_evidences.create params.require(:order_payment_evidence).permit(:file)

    redirect_to order_path(@order.order_id)
  end
end
