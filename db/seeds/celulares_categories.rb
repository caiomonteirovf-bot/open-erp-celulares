# frozen_string_literal: true

# Categorias e NCMs específicos para loja de celulares.
# Idempotente: usa find_or_create_by para não duplicar em re-runs.

CELULAR_CATEGORIES = [
  { name: 'Smartphones',  ncm_code: '8517.13.00', ncm_description: 'Aparelhos telefônicos por fio com unidade auscultador-microfone sem fio' },
  { name: 'Capas',        ncm_code: '3926.90.90', ncm_description: 'Outras obras de plástico' },
  { name: 'Películas',    ncm_code: '3919.90.00', ncm_description: 'Chapas, folhas, fitas, tiras, de plástico, autoadesivas' },
  { name: 'Carregadores', ncm_code: '8504.40.40', ncm_description: 'Carregadores de acumuladores' },
  { name: 'Cabos',        ncm_code: '8544.42.00', ncm_description: 'Condutores elétricos para tensão não superior a 1000 V' },
  { name: 'Fones',        ncm_code: '8518.30.00', ncm_description: 'Fones de ouvido, mesmo combinados com microfone' },
  { name: 'Power Banks',  ncm_code: '8507.60.00', ncm_description: 'Acumuladores de íons de lítio' },
  { name: 'Peças',        ncm_code: '8517.79.90', ncm_description: 'Partes para aparelhos de telefonia' }
].freeze

account_id = Account.first&.id

if account_id.nil?
  Rails.logger.warn 'SEED celulares_categories: nenhuma conta encontrada, pulando criação de categorias.'
  return
end

ActsAsTenant.with_tenant(Account.find(account_id)) do
  CELULAR_CATEGORIES.each do |attrs|
    cat = Category.find_or_initialize_by(name: attrs[:name], account_id: account_id)
    cat.assign_attributes(ncm_code: attrs[:ncm_code], ncm_description: attrs[:ncm_description])
    cat.save!
    Rails.logger.debug "  Categoria: #{cat.name} (#{cat.ncm_code}) — #{cat.persisted? ? 'ok' : 'erro'}"
  end
end

Rails.logger.debug "Categorias celulares: #{CELULAR_CATEGORIES.size} registros verificados."
