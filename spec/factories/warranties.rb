# frozen_string_literal: true

FactoryBot.define do
  factory :warranty do
    warranty_type { 'loja' }
    started_at    { Date.current }
    expires_at    { Date.current + 12.months }

    association :phone_unit
    association :account
  end

  trait :fabrica do
    warranty_type { 'fabrica' }
    expires_at    { Date.current + 12.months }
  end

  trait :expiring_soon do
    expires_at { Date.current + 15.days }
  end

  trait :expired do
    started_at { 2.years.ago }
    expires_at { 1.day.ago }
  end
end
