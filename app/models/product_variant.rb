class ProductVariant < ApplicationRecord
  belongs_to :product

  validates :name, presence: true
  validates :price, numericality: { greater_than_or_equal_to: 0 }, presence: true
  validates :weight, numericality: { greater_than_or_equal_to: 0 }, allow_nil: true
  validates :stock, numericality: { greater_than_or_equal_to: 0 }, presence: true
  validates :is_active, inclusion: { in: [ true, false ] }

  scope :active, -> { where(is_active: true) }
  scope :in_stock, -> { where("stock > 0") }
end
