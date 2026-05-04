# frozen_string_literal: true

FactoryBot.define do
  factory :service_order do
    reported_defect { 'Tela quebrada' }
    status          { 'aberta' }
    labor_cost      { 80.0 }
    device_brand    { 'Samsung' }
    device_model    { 'Galaxy S23' }
    device_imei     { '356938035643809' }

    association :customer
    association :account
  end

  factory :service_order_item do
    description { 'Troca de tela' }
    quantity    { 1 }
    unit_price  { 250.0 }

    association :service_order
  end
end
