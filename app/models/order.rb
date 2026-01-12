class Order < ApplicationRecord
  belongs_to :cart

  has_many :line_items, class_name: "OrderLineItem", dependent: :delete_all
  has_many :payment_evidences, -> { order(created_at: :desc) }, as: :payable, dependent: :destroy

  belongs_to :shipping_cost_record, class_name: "ShippingCost", optional: true, foreign_key: "shipping_cost_id"
  belongs_to :shipping_province, class_name: "Province", optional: true
  belongs_to :shipping_city, class_name: "City", optional: true
  belongs_to :shipping_district, class_name: "District", optional: true
  belongs_to :shipping_subdistrict, class_name: "Subdistrict", optional: true

  enum :state, %w[ pending paid failed expired ]

  before_save -> { self.state_updated_at = Time.now }, if: :state_changed?
  before_create -> { self.order_id = SecureRandom.uuid }

  after_save_commit :decrement_variant_stock, if: -> { saved_change_to_state? && paid? }
  after_save_commit :send_order_successful_notification, if: -> { saved_change_to_state? && paid? }
  after_save_commit :send_order_failed_notification, if: -> { saved_change_to_state? && failed? }
  after_create_commit :send_order_created_notification, if: -> { Current.settings["payment_provider"] == "manual" }

  scope :today, -> { where(state_updated_at: Time.now.all_day) }

  validates :customer_agree_to_terms, acceptance: true
  validates :customer_phone, presence: true, if: :contains_physical_products?
  validates :address_line, presence: true, if: :contains_physical_products?
  validates :shipping_province_id, presence: true, if: :contains_physical_products?
  validates :shipping_city_id, presence: true, if: :contains_physical_products?
  validates :shipping_cost_id, presence: true, if: :contains_physical_products?
  validate :address_hierarchy_consistency
  validate :shipping_cost_consistency

  def contains_physical_products?
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

  def decrement_variant_stock
    line_items.each do |line_item|
      next unless line_item.product_variant

      line_item.product_variant.with_lock do
        line_item.product_variant.decrement!(:stock)
      end
    end
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
end
