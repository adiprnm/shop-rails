class Donations::PaymentEvidencesController < ApplicationController
  def new
    @donation = Donation.find_by!(donation_id: params[:support_id])
    @payment_evidence = PaymentEvidence.new
  end

  def create
    @donation = Donation.find_by!(donation_id: params[:support_id])
    @payment_evidence = @donation.payment_evidences.create(payment_evidence_params)

    if @payment_evidence.valid?
      redirect_to support_path(@donation.donation_id)
    else
      render "new", status: :unprocessable_entity
    end
  end

  private

  def payment_evidence_params
    params.require(:payment_evidence).permit(:file)
  end
end
