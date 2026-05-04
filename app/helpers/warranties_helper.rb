# frozen_string_literal: true

module WarrantiesHelper
  STATUS_BADGE = {
    active:        'bg-success',
    expiring_soon: 'bg-warning text-dark',
    expired:       'bg-danger'
  }.freeze

  def warranty_status_badge(status)
    STATUS_BADGE.fetch(status, 'bg-secondary')
  end

  def warranty_days_label(warranty)
    days = warranty.days_remaining
    if days < 0
      t('warranties.expired_days_ago', count: days.abs)
    elsif days.zero?
      t('warranties.expires_today')
    else
      t('warranties.expires_in_days', count: days)
    end
  end
end
