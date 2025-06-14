class Product < ApplicationRecord
  delegated_type :productable, types: %w[ DigitalProduct ]
  has_one_attached :featured_image

  enum :state, %w[ inactive active ]

  def self.create_with_productable(product_params, productable_params)
    productable_type = product_params.delete(:productable_type)

    productable = case productable_type
    when "digital_product"
      DigitalProduct.new(**productable_params)
    end

    Product.create(productable: productable, **product_params)
  end
end
