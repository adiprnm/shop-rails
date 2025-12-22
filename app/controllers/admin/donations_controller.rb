class Admin::DonationsController < AdminController
  before_action :set_donation, only: %w[ show edit update destroy ]

  def index
    @donations = Donation.all.order(created_at: :desc)
  end

  def show; end
  def edit; end

  def update
    @donation.update(params.require(:donation).permit(:name, :amount, :message, :state))

    redirect_to admin_donation_path(@donation)
  end

  def destroy
    @donation.destroy

    redirect_to admin_donations_path
  end

  private
    def set_donation
      @donation = Donation.find(params[:id])
    end
end
