class Donation < ApplicationRecord
  include Payable

  validates :amount, comparison: { greater_than_or_equal_to: 5000 }
  validates :message, presence: true

  enum :state, %w[ pending paid failed expired ].index_by(&:itself)

  before_create :set_donation_id

  after_create :send_donation_created_notification
  after_save_commit :send_donate_successful_notification, if: -> { saved_change_to_state? && paid? }
  after_save_commit :send_donate_failed_notification, if: -> { saved_change_to_state? && failed? }

  def set_donation_id
    self.donation_id = SecureRandom.uuid
  end

  def name
    super.presence || "Seseorang"
  end

  def expire?
    Time.now > will_expire_at && pending?
  end

  def will_expire_at
    (created_at + 1.day).in_time_zone(Current.time_zone)
  end

  private
    def send_donation_created_notification
      Notification.with(donation: self).notify_created
    end

  def send_donate_successful_notification
    notification = Notification.with(donation: self)

    if Current.settings["payment_provider"] == "midtrans"
      notification.notify_admin
    end

    if email_address?
      notification.notify_donor
    end

    notification.notify_telegram_admin
  end

    def send_donate_failed_notification
      Notification.with(donation: self).notify_failed if email_address?
    end
end
