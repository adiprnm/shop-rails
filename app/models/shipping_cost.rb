class ShippingCost < ApplicationRecord
  CACHE_TTL = 24.hours

  validates :origin_type, presence: true
  validates :origin_id, presence: true
  validates :destination_type, presence: true
  validates :destination_id, presence: true
  validates :weight, presence: true
  validates :courier, presence: true
  validates :service, presence: true
  validates :cost, presence: true, numericality: { greater_than_or_equal_to: 0 }

  scope :fresh, -> { where("created_at > ?", CACHE_TTL.ago) }

  def self.find_or_fetch(origin, destination, weight, courier, service)
    origin_type = origin.class.name
    origin_id = origin.id
    destination_type = destination.class.name
    destination_id = destination.id

    fresh_records = fresh.find_by(
      origin_type: origin_type,
      origin_id: origin_id,
      destination_type: destination_type,
      destination_id: destination_id,
      weight: weight,
      courier: courier,
      service: service
    )

    return fresh_records if fresh_records

    new_cost = yield
    new_cost&.save
    new_cost
  end

  def calculate
    cost
  end
end
