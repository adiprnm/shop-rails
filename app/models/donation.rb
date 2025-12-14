class Donation < ApplicationRecord
  validates :amount, comparison: { greater_than_or_equal_to: 5000 }

  enum :state, %w[ pending paid failed expired ].index_by(&:itself)

  before_create :set_donation_id
  before_save :set_state_updated_at, if: :state_changed?

  after_save_commit :send_donate_successful_notification, if: -> { saved_change_to_state? && paid? }

  def set_donation_id
    self.donation_id = SecureRandom.uuid
  end

  def name
    super.presence || "Seseorang"
  end

  def set_state_updated_at
    self.state_updated_at = Time.now
  end

  private
    def send_donate_successful_notification
      Notification.with(donation: self).notify_admin
    end
end
