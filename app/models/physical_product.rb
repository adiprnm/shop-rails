class PhysicalProduct < ApplicationRecord
  has_one :product, as: :productable, dependent: :destroy
  has_many :product_variants, dependent: :destroy
end
