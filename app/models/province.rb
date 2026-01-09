class Province < ApplicationRecord
  has_many :cities, dependent: :destroy

  validates :rajaongkir_id, presence: true, uniqueness: true
  validates :name, presence: true
end
