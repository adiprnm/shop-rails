class Order < ApplicationRecord
  belongs_to :cart

  has_many :line_items, class_name: "OrderLineItem", dependent: :delete_all
  has_many :payment_evidences, -> { order(created_at: :desc) }, as: :payable, dependent: :destroy
  has_many :coupon_usages, dependent: :destroy

  belongs_to :shipping_cost_record, class_name: "ShippingCost", optional: true, foreign_key: "shipping_cost_id"

  has_one :coupon_usage, dependent: :destroy
  has_one :applied_coupon, through: :coupon_usage, source: :coupon
  belongs_to :shipping_province, class_name: "Province", optional: true
  belongs_to :shipping_city, class_name: "City", optional: true
  belongs_to :shipping_district, class_name: "District", optional: true
  belongs_to :shipping_subdistrict, class_name: "Subdistrict", optional: true

  enum :state, %w[ pending paid failed expired ]

  before_save -> { self.state_updated_at = Time.now }, if: :state_changed?
  before_save -> { self.tracking_number_updated_at = Time.now }, if: :tracking_number_changed?
  before_create -> { self.order_id = SecureRandom.uuid }
  before_create -> { self.unique_code = generate_unique_code }, if: -> { Current.settings["payment_provider"] == "manual" }

  after_save_commit :decrement_variant_stock, if: -> { saved_change_to_state? && paid? }
  after_save_commit :send_order_successful_notification, if: -> { saved_change_to_state? && paid? }
  after_save_commit :send_order_failed_notification, if: -> { saved_change_to_state? && failed? }
  after_create_commit :send_order_created_notification, if: -> { Current.settings["payment_provider"] == "manual" }
  after_save_commit :send_shipping_tracking_notification, if: -> { saved_change_to_tracking_number? && tracking_number.present? }

  before_create :capture_coupon_details
  after_create :record_coupon_usage

  scope :today, -> { where(state_updated_at: Time.now.all_day) }

  validates :customer_agree_to_terms, acceptance: true
  validates :customer_phone, presence: true, if: :shipping_required?
  validates :address_line, presence: true, if: :shipping_required?
  validates :shipping_province_id, presence: true, if: :shipping_required?
  validates :shipping_city_id, presence: true, if: :shipping_required?
  validates :shipping_cost_id, presence: true, if: :shipping_required?
  validate :address_hierarchy_consistency
  validate :shipping_cost_consistency

  def contains_physical_products?
    has_physical_products == true
  end

  def requires_shipping?
    cart && cart.contains_physical_product?
  end

  def shipping_required?
    has_physical_products == true
  end

  def latest_payment_evidence
    payment_evidences.first
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

  def generate_unique_code
    max_code = (Current.settings["manual_payment_unique_code_max"] || 500).to_i
    attempts = 0
    max_attempts = 100

    loop do
      code = rand(1..max_code)
      conflicting_order = Order.where(unique_code: code, state: %w[pending failed]).exists?

      unless conflicting_order
        return code
      end

      attempts += 1
      raise "Unable to generate unique code after #{max_attempts} attempts" if attempts >= max_attempts
    end
  end

  def decrement_variant_stock
    line_items.each do |line_item|
      next unless line_item.product_variant

      line_item.product_variant.with_lock do
        line_item.product_variant.decrement!(:stock)
      end
    end
  end

  def final_total_price
    total_price.to_i + unique_code.to_i
  end

  def subtotal_price
    line_items.sum(&:orderable_price)
  end

  def coupon_discount_amount
    self[:coupon_discount_amount] || 0
  end

  def shipping_cost
    self[:shipping_cost] || 0
  end

  def has_coupon?
    coupon_code.present?
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

    def send_shipping_tracking_notification
      Notification.with(order: self).notify_tracking_number
    end

    def address_hierarchy_consistency
      return unless shipping_province_id && shipping_city_id && shipping_district_id && shipping_subdistrict_id

      if shipping_city
        unless shipping_city.province_id == shipping_province_id
          errors.add(:shipping_city_id, "must belong to the selected province")
        end
      end

      if shipping_district
        unless shipping_district.city_id == shipping_city_id
          errors.add(:shipping_district_id, "must belong to the selected city")
        end
      end

      if shipping_subdistrict
        unless shipping_subdistrict.district_id == shipping_district_id
          errors.add(:shipping_subdistrict_id, "must belong to the selected district")
        end
      end
    end

    def shipping_cost_consistency
      return unless contains_physical_products? && shipping_cost_id

      cost_record = shipping_cost_record
      unless cost_record
        errors.add(:shipping_cost_id, "must be valid")
        return
      end

      if shipping_district_id
        unless cost_record.destination_type == "District" && cost_record.destination_id == shipping_district_id
          errors.add(:shipping_cost_id, "must match the selected shipping district")
        end
      elsif shipping_city_id
        unless cost_record.destination_type == "City" && cost_record.destination_id == shipping_city_id
          errors.add(:shipping_cost_id, "must match the selected shipping city")
        end
      elsif shipping_province_id
        unless cost_record.destination_type == "Province" && cost_record.destination_id == shipping_province_id
          errors.add(:shipping_cost_id, "must match the selected shipping province")
        end
      end
    end

    def capture_coupon_details
      return unless cart

      if cart.coupon_code.present?
        self.coupon_code = cart.coupon_code
        self.coupon_discount_amount = cart.coupon&.calculate_discount(cart) || 0

        base_total = cart.subtotal_price + shipping_cost
        self.total_price = [ base_total - coupon_discount_amount, 0 ].max
      end
    end

    def record_coupon_usage
      return unless cart&.coupon && coupon_code.present?

      cart.coupon.record_usage!(self)
    end
end
