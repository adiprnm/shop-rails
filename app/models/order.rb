class Order < ApplicationRecord
  belongs_to :cart

  has_many :line_items, class_name: "OrderLineItem", dependent: :delete_all
  has_many :payment_evidences, -> { order(created_at: :desc) }, as: :payable, dependent: :destroy

  enum :state, %w[ pending paid failed expired ]

  before_save -> { self.state_updated_at = Time.now }, if: :state_changed?
  before_create -> { self.order_id = SecureRandom.uuid }

  after_save_commit :send_order_successful_notification, if: -> { saved_change_to_state? && paid? }
  after_save_commit :send_order_failed_notification, if: -> { saved_change_to_state? && failed? }
  after_create_commit :send_order_created_notification, if: -> { Current.settings["payment_provider"] == "manual" }

  scope :today, -> { where(state_updated_at: Time.now.all_day) }

  validates :customer_agree_to_terms, acceptance: true

  def latest_payment_evidence
    payment_evidences.first
  end

  def expire?
    Time.now > will_expire_at && pending?
  end

  def will_expire_at
    (created_at + 1.day).in_time_zone(Current.time_zone)
  end

  private
    def send_order_successful_notification
      Notification.with(order: self).notify
    end

    def send_order_created_notification
      Notification.with(order: self).notify_created
    end

    def send_order_failed_notification
      Notification.with(order: self).notify_failed
    end
end
