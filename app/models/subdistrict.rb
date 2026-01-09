class Subdistrict < ApplicationRecord
  belongs_to :district

  validates :rajaongkir_id, presence: true, uniqueness: true
  validates :name, presence: true
end
