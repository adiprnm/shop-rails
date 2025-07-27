class Order < ApplicationRecord
  belongs_to :cart

  has_many :line_items, class_name: "OrderLineItem", dependent: :delete_all

  enum :state, %w[ pending paid failed ]

  before_save -> { self.state_updated_at = Time.now }, if: :state_changed?
  before_create -> { self.order_id = SecureRandom.uuid }
  after_save_commit :send_order_successful_notification, if: -> { saved_change_to_state? && paid? }

  validates :customer_agree_to_terms, acceptance: true

  private
    def send_order_successful_notification
      Notification.with(order: self).notify
    end
end
