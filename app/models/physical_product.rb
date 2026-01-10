class PhysicalProduct < ApplicationRecord
  has_one :product, as: :productable, dependent: :destroy
  has_many :product_variants, dependent: :destroy

  accepts_nested_attributes_for :product_variants, allow_destroy: true

  validates :weight, numericality: { greater_than: 0 }, allow_nil: true
  validates :requires_shipping, inclusion: { in: [ true, false ] }

  validate :at_least_one_active_variant

  private

  def at_least_one_active_variant
    return unless product_variants.present?

    active_variants = product_variants.reject(&:marked_for_destruction?)
    unless active_variants.any?(&:is_active)
      errors.add(:product_variants, "must have at least one active variant")
    end
  end
end
