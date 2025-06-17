class OrderLineItem < ApplicationRecord
  belongs_to :order
  belongs_to :orderable, polymorphic: true
  belongs_to :productable, polymorphic: true

  def digital_product?
    productable_type == "DigitalProduct"
  end

  def physical_product?
    productable_type == "PhysicalProduct"
  end
end
