class DonationsController < ApplicationController
  def index
    @donation = Donation.new
    @donations = Donation.paid.order(created_at: :desc)
  end

  def create
    @donation = Donation.pending.create(donation_params)

    if @donation.valid?
      begin
        Transaction::Payment.cancel(@donation.donation_id)
      rescue MidtransClient::Error => e
        raise StandardError, e if e.message.exclude?("404")
      ensure
        @donation.donation_id = SecureRandom.uuid
        @donation.save
      end

      payment = Transaction::Payment.new(@donation)
      redirect_to payment.payment_url, allow_other_host: true
    else
      redirect_to supports_path, alert: @donation.errors.full_messages.first
    end
  end

  private
    def donation_params
      params.require(:donation).permit(:name, :message, :amount)
    end
end
