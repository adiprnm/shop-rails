class Page < ApplicationRecord
  enum :state, %w[ draft published ].index_by(&:itself)

  validates :title, presence: true
  validates :description, presence: true
  validates :state, presence: true
  validates :slug, presence: true, uniqueness: true

  before_validation :set_slug, if: -> { slug.blank? && title.present? }
  before_save :set_state_updated_at, if: -> { state_changed? || state_updated_at.blank? }

  def set_slug
    self.slug = title.parameterize
  end

  def set_state_updated_at
    self.state_updated_at ||= Time.now
  end
end
