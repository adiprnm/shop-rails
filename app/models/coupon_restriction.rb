class CouponRestriction < ApplicationRecord
  self.inheritance_column = nil

  belongs_to :coupon
  belongs_to :restriction, polymorphic: true

  validates :restriction_kind, presence: true, inclusion: { in: %w[include exclude] }
  validates :restriction, presence: true

  scope :include, -> { where(restriction_kind: "include") }
  scope :exclude, -> { where(restriction_kind: "exclude") }
  scope :products, -> { where(restriction_type: "Product") }
  scope :categories, -> { where(restriction_type: "Category") }
end
