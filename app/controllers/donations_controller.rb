class DonationsController < ApplicationController
  def index
    @donation = Donation.new
    @donations = Donation.paid.order(created_at: :desc)
  end

  def create
    @donation = Donation.pending.create(donation_params)

    if @donation.valid?
      redirect_url = Transaction::Payment.for(@donation).redirect_url
      redirect_to redirect_url, allow_other_host: true
    else
      redirect_to supports_path, alert: @donation.errors.full_messages.first
    end
  end

  def show
    @donation = Donation.find_by! donation_id: params[:id]
    @donation.expired! if @donation.expire?
  end

  private
    def donation_params
      params.require(:donation).permit(:name, :message, :amount, :email_address)
    end
end
