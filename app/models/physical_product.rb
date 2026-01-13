class PhysicalProduct < ApplicationRecord
  has_one :product, as: :productable, dependent: :destroy
  has_many :product_variants, through: :product, source: :product_variants

  validates :weight, numericality: { greater_than: 0 }, allow_nil: true
  validates :requires_shipping, inclusion: { in: [ true, false ] }

  validate :at_least_one_active_variant

  private

  def at_least_one_active_variant
    return unless product.present? && product.product_variants.present?

    unless product.product_variants.active.any?
      errors.add(:product_variants, "must have at least one active variant")
    end
  end
end
