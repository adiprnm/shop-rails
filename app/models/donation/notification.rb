class Donation::Notification
  attr_reader :donation

  def self.with(donation:)
    new(donation)
  end

  def initialize(donation)
    @donation = donation
  end

  def notify_admin
    DonationMailer.with(donation: donation).admin_notification.deliver_later
  end
end
