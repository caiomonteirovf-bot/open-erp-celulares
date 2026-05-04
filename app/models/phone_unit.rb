# frozen_string_literal: true

# == Schema Information
#
# Table name: phone_units
#
#  id             :bigint           not null, primary key
#  battery_health :integer
#  color          :string
#  condition      :string
#  imei1          :string           not null
#  imei2          :string
#  notes          :text
#  purchase_price :decimal(10, 2)
#  sale_price     :decimal(10, 2)
#  serial_number  :string
#  status         :string           not null, default "em_estoque"
#  created_at     :datetime         not null
#  updated_at     :datetime         not null
#  account_id     :integer          not null
#  product_id     :bigint           not null
#
# Indexes
#
#  index_phone_units_on_account_id     (account_id)
#  index_phone_units_on_imei1          (imei1) UNIQUE
#  index_phone_units_on_imei2          (imei2) UNIQUE WHERE imei2 IS NOT NULL AND imei2 != ''
#  index_phone_units_on_serial_number  (serial_number) UNIQUE WHERE serial_number IS NOT NULL AND serial_number != ''
#  index_phone_units_on_status         (status)
#
# Foreign Keys
#
#  fk_rails_...  (product_id => products.id)
#
class PhoneUnit < ApplicationRecord
  VALID_STATUSES   = %w[em_estoque vendido em_servico devolvido perdido].freeze
  VALID_CONDITIONS = %w[novo seminovo usado vitrine].freeze
  IMEI_FORMAT      = /\A\d{15}\z/

  acts_as_tenant :account

  belongs_to :product

  validates :imei1, presence: true,
                    format: { with: IMEI_FORMAT, message: :invalid_imei },
                    uniqueness: { case_sensitive: false }

  validates :imei2,
            format: { with: IMEI_FORMAT, message: :invalid_imei },
            uniqueness: { case_sensitive: false },
            allow_nil: true, allow_blank: true

  validates :status,    presence: true, inclusion: { in: VALID_STATUSES }
  validates :condition, inclusion: { in: VALID_CONDITIONS }, allow_nil: true
  validates :battery_health, numericality: { only_integer: true, in: 1..100 }, allow_nil: true
  validates :purchase_price, numericality: { greater_than_or_equal_to: 0 }, allow_nil: true
  validates :sale_price,     numericality: { greater_than_or_equal_to: 0 }, allow_nil: true

  scope :em_estoque,  -> { where(status: 'em_estoque') }
  scope :vendidos,    -> { where(status: 'vendido') }
  scope :em_servico,  -> { where(status: 'em_servico') }
  scope :by_imei,     ->(imei) { where('imei1 ILIKE ? OR imei2 ILIKE ?', "%#{imei}%", "%#{imei}%") }

  def em_estoque?  = status == 'em_estoque'
  def vendido?     = status == 'vendido'
  def em_servico?  = status == 'em_servico'

  def vender!
    update!(status: 'vendido')
  end

  def devolver!
    update!(status: 'devolvido')
  end
end
