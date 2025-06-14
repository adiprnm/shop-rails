class DigitalProduct < ApplicationRecord
  has_one_attached :resource
  has_one :product, as: :productable, dependent: :destroy

  enum :resource_type, %w[ file url ]
end
