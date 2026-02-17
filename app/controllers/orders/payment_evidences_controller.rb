class Orders::PaymentEvidencesController < ApplicationController
  def new
    @order = Order.find_by!(order_id: params[:order_id])
    @payment_evidence = PaymentEvidence.new
  end

  def create
    @order = Order.find_by!(order_id: params[:order_id])
    @order.payment_evidences.create(payment_evidence_params)

    redirect_to order_path(@order.order_id)
  end

  private

  def payment_evidence_params
    params.require(:payment_evidence).permit(:file)
  end
end
