class Order < ApplicationRecord
  belongs_to :cart

  has_many :line_items, class_name: "OrderLineItem", dependent: :delete_all

  enum :state, %w[ pending paid failed ]

  before_save -> { self.state_updated_at = Time.now }, if: :state_changed?
  before_create -> { self.order_id = SecureRandom.uuid }
  after_save_commit :send_order_successful_email, if: -> { saved_change_to_state? && paid? }

  validates :customer_agree_to_terms, acceptance: true

  private
    def send_order_successful_email
      products = line_items.to_a
      OrderMailer.with(order: self, products: products).order_invoice.deliver_later

      digital_products = products.select(&:digital_product?)
      if digital_products.present?
        OrderMailer.with(order: self, products: digital_products).digital_product_accesses.deliver_later
      end
    end
end
