class City < ApplicationRecord
  belongs_to :province
  has_many :districts, dependent: :destroy

  validates :rajaongkir_id, presence: true, uniqueness: true
  validates :name, presence: true

  default_scope { order(name: :asc) }

  def self.find_by_rajaongkir_id(rajaongkir_id)
    find_by(rajaongkir_id: rajaongkir_id)
  end
end
