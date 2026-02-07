class ProductRecommendation < ApplicationRecord
  belongs_to :source_product, class_name: "Product"
  belongs_to :recommended_product, class_name: "Product"

  enum :recommendation_type, %w[ upsell cross_sell ].index_by(&:itself)

  validates :source_product_id, uniqueness: {
    scope: [ :recommended_product_id, :recommendation_type ]
  }
  validate :cannot_recommend_self

  scope :upsell, -> { where(recommendation_type: "upsell") }
  scope :cross_sell, -> { where(recommendation_type: "cross_sell") }
  scope :ordered, -> { order(:position, :id) }

  private

  def cannot_recommend_self
    errors.add(:recommended_product, "cannot be same as source product") if source_product_id == recommended_product_id
  end
end
