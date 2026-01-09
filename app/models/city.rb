class City < ApplicationRecord
  belongs_to :province
  has_many :districts, dependent: :destroy

  validates :rajaongkir_id, presence: true, uniqueness: true
  validates :name, presence: true
end
