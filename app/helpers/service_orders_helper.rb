# frozen_string_literal: true

module ServiceOrdersHelper
  STATUS_BADGE = {
    'aberta'          => 'bg-primary',
    'em_andamento'    => 'bg-warning text-dark',
    'aguardando_peca' => 'bg-secondary',
    'pronta'          => 'bg-success',
    'entregue'        => 'bg-dark',
    'cancelada'       => 'bg-danger'
  }.freeze

  def so_status_badge(status)
    STATUS_BADGE.fetch(status, 'bg-secondary')
  end
end
