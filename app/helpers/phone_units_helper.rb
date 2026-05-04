# frozen_string_literal: true

module PhoneUnitsHelper
  STATUS_BADGE = {
    'em_estoque' => 'bg-success',
    'vendido'    => 'bg-secondary',
    'em_servico' => 'bg-warning text-dark',
    'devolvido'  => 'bg-info text-dark',
    'perdido'    => 'bg-danger'
  }.freeze

  def status_badge_class(status)
    STATUS_BADGE.fetch(status, 'bg-secondary')
  end
end
