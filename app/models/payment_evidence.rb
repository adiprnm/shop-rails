class PaymentEvidence < ApplicationRecord
  belongs_to :payable, polymorphic: true

  has_one_attached :file

  after_create :notify_admin
  after_create :notify_telegram_admin
  after_create :update_payable, unless: -> { payable.pending? }

  def notify_admin
    klass = payable_type.constantize
    klass::Notification.new(payable).notify_admin
  end

  def notify_telegram_admin
    case payable_type
    when "Order"
      TelegramNotificationJob.perform_later(payable.id, :evidence_uploaded)
    when "Donation"
      DonationNotificationJob.perform_later(payable.id, :evidence_uploaded)
    end
  end

  def update_payable
    payable.update state: "pending"
  end
end
