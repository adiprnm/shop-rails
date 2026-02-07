class Product < ApplicationRecord
  delegated_type :productable, types: %w[ DigitalProduct PhysicalProduct ]

  has_one_attached :featured_image
  has_many_attached :images
  has_and_belongs_to_many :categories

  has_many :product_variants, dependent: :destroy, inverse_of: :product
  accepts_nested_attributes_for :product_variants, allow_destroy: true, reject_if: :all_blank
  has_many :order_line_items, as: :orderable
  has_many :completed_orders, -> { paid }, through: :order_line_items, source: :order
  has_many :coupon_restrictions, as: :restriction, dependent: :nullify

  has_many :source_recommendations, class_name: "ProductRecommendation",
           foreign_key: :source_product_id, dependent: :destroy,
           inverse_of: :source_product
  has_many :received_recommendations, class_name: "ProductRecommendation",
           foreign_key: :recommended_product_id, dependent: :destroy

  has_many :upsell_products, through: :source_recommendations,
           source: :recommended_product, class_name: "Product"
  has_many :cross_sell_products, through: :source_recommendations,
           source: :recommended_product, class_name: "Product"

  scope :with_completed_orders, lambda {
    left_joins(order_line_items: :order)
      .group("products.id")
      .select("products.*, COUNT(orders.id) AS total_completed_orders")
  }

  enum :state, %w[ inactive active ]
  enum :display_type, %w[ full compact_list ].index_by(&:itself)

  attr_writer :upsell_product_ids, :cross_sell_product_ids

  after_save :update_recommendations

  def self.create_with_productable(product_params, productable_params)
    productable_type = product_params.delete(:productable_type)

    productable = case productable_type
    when "DigitalProduct"
      DigitalProduct.new(**productable_params)
    when "PhysicalProduct"
      PhysicalProduct.new(**productable_params)
    end

    product = Product.new(productable: productable, **product_params.to_h)
    product.save!
    product
  end

  def sale_price?
    return false unless sale_price
    return false if sale_price_starts_at? && sale_price_starts_at > Time.now
    return false if sale_price_ends_at? && sale_price_ends_at < Time.now

    true
  end

  def actual_price
    sale_price? ? sale_price : price
  end

  def coming_soon?
    return false if physical_product?
    productable.resource_path.blank?
  end

  def physical_product?
    productable_type == "PhysicalProduct"
  end

  def physical?
    productable_type == "PhysicalProduct"
  end

  def digital?
    productable_type == "DigitalProduct"
  end

  def upsell_product_ids
    @upsell_product_ids ||= source_recommendations.upsell.pluck(:recommended_product_id)
  end

  def cross_sell_product_ids
    @cross_sell_product_ids ||= source_recommendations.cross_sell.pluck(:recommended_product_id)
  end

  def active_upsells(limit: 4)
    source_recommendations.upsell.ordered.limit(limit)
      .joins(:recommended_product)
      .merge(Product.active)
      .includes(:recommended_product)
  end

  def active_cross_sells(limit: 4)
    source_recommendations.cross_sell.ordered.limit(limit)
      .joins(:recommended_product)
      .merge(Product.active)
      .includes(:recommended_product)
  end

  def self.cart_recommendations(cart, limit: 4)
    return none unless cart.line_items.present?

    product_ids = cart.line_items.pluck(:cartable_id)

    recommended_products = joins(:received_recommendations)
      .where(received_recommendations: { source_product_id: product_ids })
      .active
      .distinct

    recommended_products_ids = recommended_products.pluck(:id).sample([ limit, recommended_products.count ].min)
    recommended_products_ids -= product_ids

    where(id: recommended_products_ids).limit(limit)
  end

  private

  def update_recommendations
    update_recommendation_type(:upsell, @upsell_product_ids) if @upsell_product_ids
    update_recommendation_type(:cross_sell, @cross_sell_product_ids) if @cross_sell_product_ids
  end

  def update_recommendation_type(type, new_ids)
    new_ids = new_ids.reject(&:blank?).map(&:to_i)
    current_ids = source_recommendations.send(type).pluck(:recommended_product_id)

    ids_to_remove = current_ids - new_ids
    source_recommendations.send(type).where(recommended_product_id: ids_to_remove).destroy_all

    ids_to_add = new_ids - current_ids
    ids_to_add.each_with_index do |product_id, index|
      source_recommendations.create!(
        recommended_product_id: product_id,
        recommendation_type: type.to_s,
        position: index
      )
    end

    new_ids.each_with_index do |product_id, index|
      recommendation = source_recommendations.send(type).find_by(recommended_product_id: product_id)
      recommendation.update(position: index) if recommendation
    end
  end
end
