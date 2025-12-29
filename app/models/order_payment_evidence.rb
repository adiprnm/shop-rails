class OrderPaymentEvidence < ApplicationRecord
  belongs_to :order

  has_one_attached :file

  after_create :notify_admin, :update_order

  def notify_admin
    Order::Notification.with(order: order).notify_admin
  end

  def update_order
    order.update has_unchecked_payment_evidence: true, state: "pending"
  end
end
