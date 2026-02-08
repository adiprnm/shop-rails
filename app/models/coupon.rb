class Coupon < ApplicationRecord
  enum :discount_type, %w[fixed_cart percent_cart fixed_product percent_product free_shipping].index_by(&:itself)
  enum :state, %w[active inactive expired].index_by(&:itself)

  validates :code, presence: true, uniqueness: { case_sensitive: false }
  validates :discount_amount, presence: true,
    if: -> { discount_type.in?(%w[fixed_cart percent_cart fixed_product percent_product]) }
  validates :minimum_amount, numericality: { greater_than_or_equal_to: 0 }
  validates :usage_limit, numericality: { greater_than: 0 }, allow_nil: true
  validates :usage_limit_per_user, numericality: { greater_than_or_equal_to: 0 }

  has_many :coupon_usages, dependent: :destroy, inverse_of: :coupon
  has_many :orders, through: :coupon_usages
  has_many :coupon_restrictions, dependent: :destroy, inverse_of: :coupon

  has_many :product_restrictions, -> { where(restriction_type: "Product") },
           class_name: "CouponRestriction"
  has_many :included_product_restrictions, -> { where(restriction_type: "Product", restriction_kind: "include") },
           class_name: "CouponRestriction"
  has_many :included_products, through: :included_product_restrictions, source: :restriction, source_type: "Product"
  has_many :excluded_product_restrictions, -> { where(restriction_type: "Product", restriction_kind: "exclude") },
           class_name: "CouponRestriction"
  has_many :excluded_products, through: :excluded_product_restrictions, source: :restriction, source_type: "Product"

  has_many :category_restrictions, -> { where(restriction_type: "Category") },
           class_name: "CouponRestriction"
  has_many :included_category_restrictions, -> { where(restriction_type: "Category", restriction_kind: "include") },
           class_name: "CouponRestriction"
  has_many :included_categories, through: :included_category_restrictions, source: :restriction, source_type: "Category"
  has_many :excluded_category_restrictions, -> { where(restriction_type: "Category", restriction_kind: "exclude") },
           class_name: "CouponRestriction"
  has_many :excluded_categories, through: :excluded_category_restrictions, source: :restriction, source_type: "Category"

  before_save -> { self.code = code.upcase }

  scope :active, -> { where(state: "active") }
  scope :valid_now, ->(now: Time.current) do
    where(state: "active")
      .where("starts_at IS NULL OR starts_at <= ?", now)
      .where("expires_at IS NULL OR expires_at >= ?", now)
  end
  scope :not_expired, -> { where("expires_at IS NULL OR expires_at >= ?", Time.current) }
  scope :started, -> { where("starts_at IS NULL OR starts_at <= ?", Time.current) }
  scope :today, -> { where(created_at: Time.now.all_day) }

  before_create :set_default_usage_count
  before_save :mark_expired_if_past_expiry

  def valid_for_cart?(cart, customer_email: nil)
    return false unless valid_now?
    return false if usage_limit_reached?
    return false if usage_limit_per_user_reached?(customer_email)
    return false unless meets_minimum_amount?(cart.subtotal_price)
    return false unless meets_maximum_amount?(cart.subtotal_price)
    return false unless meets_product_restrictions?(cart)
    return false unless meets_category_restrictions?(cart)

    true
  end

  def calculate_discount(cart)
    return 0 unless valid_for_cart?(cart)

    case discount_type
    when "fixed_cart"
      [ cart.subtotal_price, discount_amount ].min
    when "percent_cart"
      (cart.subtotal_price * discount_amount / 100.0).to_i
    when "fixed_product"
      calculate_fixed_product_discount(cart)
    when "percent_product"
      calculate_percent_product_discount(cart)
    when "free_shipping"
      cart.shipping_cost || 0
    else
      0
    end
  end

  def record_usage!(order)
    with_lock do
      increment!(:usage_count)
      coupon_usages.create!(
        order: order,
        discount_amount: order.coupon_discount_amount
      )
    end
  end

  def usage_count_for_user(email)
    return 0 if email.blank?

    orders
      .joins(:coupon_usages)
      .where(customer_email_address: email)
      .distinct
      .count
  end

  def valid_now?(now: Time.current)
    active? && started?(now: now) && not_expired?(now: now)
  end

  def started?(now: Time.current)
    starts_at.nil? || starts_at <= now
  end

  def not_expired?(now: Time.current)
    expires_at.nil? || expires_at >= now
  end

  private

  def set_default_usage_count
    self.usage_count ||= 0
  end

  def mark_expired_if_past_expiry
    self.state = "expired" if expires_at && expires_at < Time.current && state == "active"
  end

  def usage_limit_reached?
    usage_limit.present? && usage_count >= usage_limit
  end

  def usage_limit_per_user_reached?(email)
    return false if usage_limit_per_user.zero? || email.blank?

    usage_count_for_user(email) >= usage_limit_per_user
  end

  def meets_minimum_amount?(subtotal)
    subtotal >= minimum_amount
  end

  def meets_maximum_amount?(subtotal)
    maximum_amount.nil? || subtotal <= maximum_amount
  end

  def meets_product_restrictions?(cart)
    excluded_product_ids = excluded_products.pluck(:id)
    included_product_ids = included_products.pluck(:id)
    return true if included_product_ids.empty? && excluded_product_ids.empty?

    cart_product_ids = cart.line_items.map { |item| item.cartable_id }.uniq

    if excluded_product_ids.any?
      return false unless (excluded_product_ids & cart_product_ids).empty?
    end

    if included_product_ids.any?
      return false unless cart_product_ids.any? { |id| included_product_ids.include?(id) }
    end

    true
  end

  def meets_category_restrictions?(cart)
    excluded_category_ids = excluded_categories.pluck(:id)
    included_category_ids = included_categories.pluck(:id)
    return true if included_category_ids.empty? && excluded_category_ids.empty?

    cart_category_ids = cart.line_items
      .flat_map { |item| item.cartable.categories.pluck(:id) }
      .uniq

    if excluded_category_ids.any?
      return false unless (excluded_category_ids & cart_category_ids).empty?
    end

    if included_categories.any?
      return false unless cart_category_ids.any? { |id| included_category_ids.include?(id) }
    end

    true
  end

  def calculate_fixed_product_discount(cart)
    return 0 if discount_amount.blank?

    cart.line_items.sum do |item|
      next 0 unless product_eligible?(item.cartable)
      next 0 if exclude_sale_items && item.cartable.sale_price?

      item.price
    end
  end

  def calculate_percent_product_discount(cart)
    return 0 if discount_amount.blank?

    cart.line_items.sum do |item|
      next 0 unless product_eligible?(item.cartable)
      next 0 if exclude_sale_items && item.cartable.sale_price?

      (item.price * discount_amount / 100.0).to_i
    end
  end

  def product_eligible?(product)
    return false if excluded_products.include?(product)

    included_products.empty? || included_products.include?(product)
  end
end
