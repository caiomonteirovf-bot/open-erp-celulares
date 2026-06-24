# frozen_string_literal: true

# == Schema Information
#
# Table name: warranties
#
#  id              :bigint           not null, primary key
#  document_number :string
#  expires_at      :date             not null
#  notes           :text
#  started_at      :date             not null
#  warranty_type   :string           not null
#  created_at      :datetime         not null
#  updated_at      :datetime         not null
#  account_id      :integer          not null
#  phone_unit_id   :bigint           not null
#
# Indexes
#
#  index_warranties_on_account_id    (account_id)
#  index_warranties_on_expires_at    (expires_at)
#  index_warranties_on_warranty_type (warranty_type)
#
# Foreign Keys
#
#  fk_rails_...  (phone_unit_id => phone_units.id)
#
class Warranty < ApplicationRecord
  VALID_TYPES     = %w[fabrica loja].freeze
  EXPIRING_DAYS   = 30

  acts_as_tenant :account

  belongs_to :phone_unit

  validates :warranty_type, presence: true, inclusion: { in: VALID_TYPES }
  validates :started_at,    presence: true
  validates :expires_at,    presence: true
  validate  :expires_at_after_started_at

  scope :active,         -> { where('expires_at >= ?', Date.current) }
  scope :expired,        -> { where('expires_at < ?', Date.current) }
  scope :expiring_soon,  -> { active.where('expires_at <= ?', Date.current + EXPIRING_DAYS) }
  scope :by_type,        ->(type) { where(warranty_type: type) }
  scope :by_imei,        ->(imei) { joins(:phone_unit).where('phone_units.imei1 ILIKE ?', "%#{imei}%") }

  def status
    if expires_at < Date.current
      :expired
    elsif expires_at <= Date.current + EXPIRING_DAYS
      :expiring_soon
    else
      :active
    end
  end

  def days_remaining
    (expires_at - Date.current).to_i
  end

  def expired?        = status == :expired
  def expiring_soon?  = status == :expiring_soon
  def active?         = status == :active

  private

  def expires_at_after_started_at
    return unless started_at && expires_at
    errors.add(:expires_at, :before_start) if expires_at <= started_at
  end
end
