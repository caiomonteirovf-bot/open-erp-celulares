# frozen_string_literal: true

class ServiceOrderItem < ApplicationRecord
  belongs_to :service_order
  belongs_to :product, optional: true

  validates :description, presence: true
  validates :quantity,   numericality: { only_integer: true, greater_than: 0 }
  validates :unit_price, numericality: { greater_than_or_equal_to: 0 }

  before_save :calculate_total

  private

  def calculate_total
    self.total_price = (quantity || 1) * (unit_price || 0)
  end
end
