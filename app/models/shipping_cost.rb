class ShippingCost < ApplicationRecord
  CACHE_TTL = 24.hours

  belongs_to :origin, polymorphic: true
  belongs_to :destination, polymorphic: true

  validates :origin_type, presence: true
  validates :origin_id, presence: true
  validates :destination_type, presence: true
  validates :destination_id, presence: true
  validates :weight, presence: true
  validates :courier, presence: true
  validates :service, presence: true
  validates :cost, presence: true, numericality: { greater_than_or_equal_to: 0 }

  scope :fresh, -> { where("price_updated_at > ?", CACHE_TTL.ago) }
  scope :expired, -> { where("price_updated_at <= ?", CACHE_TTL.ago) }

  def fresh?
    price_updated_at && price_updated_at > CACHE_TTL.ago
  end

  def self.find_or_fetch(origin, destination, weight, courier, service)
    origin_type = origin.class.name
    origin_id = origin.id
    destination_type = destination.class.name
    destination_id = destination.id

    existing_record = find_by(
      origin_type: origin_type,
      origin_id: origin_id,
      destination_type: destination_type,
      destination_id: destination_id,
      weight: weight,
      courier: courier,
      service: service
    )

    if existing_record
      return existing_record if existing_record.fresh?

      new_cost = yield
      if new_cost
        existing_record.update(cost: new_cost.cost, price_updated_at: Time.current)
      end
      return existing_record
    end

    new_cost = yield
    if new_cost
      new_cost.price_updated_at = Time.current
      new_cost.save
    end
    new_cost
  end

  def self.purge_expired
    expired.delete_all
  end

  def self.clear_for_destination(destination)
    destination_type = destination.class.name
    destination_id = destination.id

    where(destination_type: destination_type, destination_id: destination_id).delete_all
  end

  def calculate
    cost
  end
end
