# frozen_string_literal: true

# == Schema Information
#
# Table name: service_orders
#
#  id                    :bigint    not null, primary key
#  account_id            :integer   not null
#  customer_id           :bigint    not null
#  phone_unit_id         :bigint
#  status                :string    not null, default "aberta"
#  reported_defect       :string    not null
#  diagnosis             :text
#  technician_notes      :text
#  labor_cost            :decimal(10,2) default 0
#  parts_cost            :decimal(10,2) default 0
#  total_cost            :decimal(10,2) default 0
#  promised_at           :date
#  closed_at             :datetime
#  device_brand          :string
#  device_model          :string
#  device_imei           :string
#  device_color          :string
#  device_battery_health :integer
#  accessories_received  :text
#  under_warranty        :boolean   default false
#  created_at            :datetime  not null
#  updated_at            :datetime  not null
#
class ServiceOrder < ApplicationRecord
  VALID_STATUSES = %w[aberta em_andamento aguardando_peca pronta entregue cancelada].freeze

  acts_as_tenant :account

  belongs_to :customer
  belongs_to :phone_unit, optional: true
  has_many :service_order_items, dependent: :destroy

  accepts_nested_attributes_for :service_order_items,
                                reject_if: :all_blank,
                                allow_destroy: true

  validates :reported_defect, presence: true
  validates :status, presence: true, inclusion: { in: VALID_STATUSES }
  validates :labor_cost, :parts_cost, :total_cost,
            numericality: { greater_than_or_equal_to: 0 }, allow_nil: true

  before_save :calculate_total
  before_save :set_phone_unit_em_servico, if: :status_changed_to_em_andamento?
  before_save :set_phone_unit_disponivel,  if: :status_changed_to_final?

  scope :abertas,          -> { where(status: 'aberta') }
  scope :em_andamento,     -> { where(status: 'em_andamento') }
  scope :prontas,          -> { where(status: 'pronta') }
  scope :entregues,        -> { where(status: 'entregue') }
  scope :abertas_e_andamento, -> { where(status: %w[aberta em_andamento aguardando_peca]) }

  def aberta?       = status == 'aberta'
  def em_andamento? = status == 'em_andamento'
  def pronta?       = status == 'pronta'
  def entregue?     = status == 'entregue'
  def cancelada?    = status == 'cancelada'
  def closed?       = %w[entregue cancelada].include?(status)

  def number
    "#OS-#{id.to_s.rjust(5, '0')}"
  end

  private

  def calculate_total
    self.parts_cost = service_order_items.reject(&:marked_for_destruction?).sum { |i| i.total_price || 0 }
    self.total_cost = (labor_cost || 0) + parts_cost
  end

  def status_changed_to_em_andamento?
    status_changed? && status == 'em_andamento' && phone_unit.present?
  end

  def status_changed_to_final?
    status_changed? && %w[entregue cancelada].include?(status) && phone_unit.present?
  end

  def set_phone_unit_em_servico
    phone_unit.update_columns(status: 'em_servico')
  end

  def set_phone_unit_disponivel
    phone_unit.update_columns(status: 'em_estoque')
  end
end
