class District < ApplicationRecord
  belongs_to :city
  has_many :subdistricts, dependent: :destroy

  validates :rajaongkir_id, presence: true, uniqueness: true
  validates :name, presence: true
end
