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

  def notify_donor
    DonationMailer.with(donation: donation).donor_notification.deliver_later
  end

  def notify_failed
    DonationMailer.with(donation: donation).donate_failed.deliver_later
  end

  def notify_created
    DonationMailer.with(donation: donation).donation_created.deliver_later
  end
end
