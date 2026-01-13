class District < ApplicationRecord
  belongs_to :city
  has_many :subdistricts, dependent: :destroy

  validates :rajaongkir_id, presence: true, uniqueness: true
  validates :name, presence: true

  default_scope { order(name: :asc) }

  def self.find_by_rajaongkir_id(rajaongkir_id)
    find_by(rajaongkir_id: rajaongkir_id)
  end

  def phrased
    "#{ name }, #{ city.name }, #{ city.province.name }"
  end
end
