class Product < ApplicationRecord
  delegated_type :productable, types: %w[ DigitalProduct PhysicalProduct ]

  has_one_attached :featured_image
  has_many_attached :images
  has_and_belongs_to_many :categories

  has_many :product_variants, dependent: :destroy, inverse_of: :product
  accepts_nested_attributes_for :product_variants, allow_destroy: true, reject_if: :all_blank
  has_many :order_line_items, as: :orderable
  has_many :completed_orders, -> { paid }, through: :order_line_items, source: :order

  scope :with_completed_orders, lambda {
    left_joins(order_line_items: :order)
      .group("products.id")
      .select("products.*, COUNT(orders.id) AS total_completed_orders")
  }

  enum :state, %w[ inactive active ]

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
end
