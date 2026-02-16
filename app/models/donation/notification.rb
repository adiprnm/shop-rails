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
    notify_telegram_failed
  end

  def notify_created
    DonationMailer.with(donation: donation).donation_created.deliver_later
  end

  def notify_telegram_admin
    return unless telegram_enabled?

    TelegramNotificationJob.perform_later(donation, :paid)
  end

  def notify_telegram_failed
    return unless telegram_enabled?

    TelegramNotificationJob.perform_later(donation, :failed)
  end

  private
    def telegram_enabled?
      Current.settings["telegram_enabled"] &&
        Current.settings["telegram_enabled"] == "true" &&
        Current.settings["telegram_bot_token"].present? &&
        Current.settings["telegram_chat_id"].present?
    end
end
