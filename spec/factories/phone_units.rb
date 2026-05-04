# frozen_string_literal: true

FactoryBot.define do
  factory :phone_unit do
    sequence(:imei1) { |n| (356938000000000 + n).to_s }
    status    { 'em_estoque' }
    condition { 'seminovo' }
    battery_health { rand(70..99) }
    purchase_price { rand(500..3000) }
    color { 'Preto' }

    association :product
    association :account
  end
end
