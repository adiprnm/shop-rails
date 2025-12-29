class Donation < ApplicationRecord
  validates :amount, comparison: { greater_than_or_equal_to: 5000 }

  enum :state, %w[ pending paid failed expired ].index_by(&:itself)

  has_many :payment_evidences, -> { order(created_at: :desc) }, as: :payable, dependent: :destroy

  before_create :set_donation_id
  before_save :set_state_updated_at, if: :state_changed?

  after_create :send_donation_created_notification
  after_save_commit :send_donate_successful_notification, if: -> { saved_change_to_state? && paid? }
  after_save_commit :send_donate_failed_notification, if: -> { saved_change_to_state? && failed? }

  def latest_payment_evidence
    payment_evidences.first
  end

  def set_donation_id
    self.donation_id = SecureRandom.uuid
  end

  def name
    super.presence || "Seseorang"
  end

  def set_state_updated_at
    self.state_updated_at = Time.now
  end

  def expire?
    Time.now > will_expire_at && pending?
  end

  def will_expire_at
    (created_at + 1.day).in_time_zone(Current.time_zone)
  end

  def mark_evidences_as_checked
    payment_evidences.where(checked: false).update_all(checked: true)
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
    end

    def send_donate_failed_notification
      Notification.with(donation: self).notify_failed if email_address?
    end
end
