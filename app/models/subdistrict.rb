class Subdistrict < ApplicationRecord
  belongs_to :district

  validates :rajaongkir_id, presence: true, uniqueness: true
  validates :name, presence: true

  def self.find_by_rajaongkir_id(rajaongkir_id)
    find_by(rajaongkir_id: rajaongkir_id)
  end
end
