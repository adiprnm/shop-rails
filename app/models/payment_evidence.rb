class PaymentEvidence < ApplicationRecord
  belongs_to :payable, polymorphic: true

  has_one_attached :file

  after_create :notify_admin
  after_create :update_payable, unless: -> { payable.pending? }

  def notify_admin
    klass = payable_type.constantize
    klass::Notification.new(payable).notify_admin
  end

  def update_payable
    payable.update state: "pending"
  end
end
