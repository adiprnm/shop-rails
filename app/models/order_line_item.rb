class OrderLineItem < ApplicationRecord
  belongs_to :order
  belongs_to :cartable, polymorphic: true
end
