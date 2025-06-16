class Product < ApplicationRecord
  delegated_type :productable, types: %w[ DigitalProduct ]

  has_one_attached :featured_image
  has_and_belongs_to_many :categories

  enum :state, %w[ inactive active ]

  def self.create_with_productable(product_params, productable_params)
    productable_type = product_params.delete(:productable_type)

    productable = case productable_type
    when "DigitalProduct"
      DigitalProduct.new(**productable_params)
    end

    Product.create(productable: productable, **product_params)
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
    productable.resource_path.blank?
  end
end
