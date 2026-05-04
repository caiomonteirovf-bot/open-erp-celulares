# frozen_string_literal: true

# Seed idempotente de categorias padrão para loja de celulares.
# Executa via `rails db:seed` ou diretamente com:
#   rails runner "load Rails.root.join('db/seeds/celulares_categories.rb')"
#
# NCMs conforme Tabela TIPI (Receita Federal):
#   8517.13.00 — Outros telefones para redes celulares ou sem fio
#   8518.30.00 — Fones de ouvido, mesmo combinados com microfone
#   8504.40.40 — Carregadores de acumuladores elétricos
#   8544.42.00 — Condutores elétricos, tensão ≤ 1.000 V (cabos)
#   8507.60.00 — Acumuladores de íons de lítio (power banks)
#   8517.79.90 — Outras partes de aparelhos de telecomunicação
#   3919.90.00 — Películas/chapas plásticas auto-adesivas
#   3926.90.90 — Outras obras de plástico (capas)

CELULARES_CATEGORIES = [
  {
    name: 'Smartphones',
    ncm_code: '8517.13.00',
    ncm_description: 'Outros telefones para redes celulares ou para outras redes sem fio'
  },
  {
    name: 'Fones de Ouvido',
    ncm_code: '8518.30.00',
    ncm_description: 'Fones de ouvido, mesmo combinados com microfone'
  },
  {
    name: 'Carregadores',
    ncm_code: '8504.40.40',
    ncm_description: 'Carregadores de acumuladores elétricos'
  },
  {
    name: 'Cabos',
    ncm_code: '8544.42.00',
    ncm_description: 'Condutores elétricos para tensão não superior a 1.000 V'
  },
  {
    name: 'Power Banks',
    ncm_code: '8507.60.00',
    ncm_description: 'Acumuladores de íons de lítio'
  },
  {
    name: 'Peças e Componentes',
    ncm_code: '8517.79.90',
    ncm_description: 'Outras partes de aparelhos de telecomunicação'
  },
  {
    name: 'Películas',
    ncm_code: '3919.90.00',
    ncm_description: 'Chapas, folhas e películas plásticas auto-adesivas'
  },
  {
    name: 'Capas e Acessórios',
    ncm_code: '3926.90.90',
    ncm_description: 'Outras obras de plástico'
  }
].freeze

account_id = Account.first&.id

if account_id.nil?
  Rails.logger.warn '[seeds/celulares_categories] Nenhuma conta encontrada — pulando seed de categorias.'
else
  ActsAsTenant.with_tenant(Account.find(account_id)) do
    CELULARES_CATEGORIES.each do |attrs|
      cat = Category.find_or_initialize_by(name: attrs[:name])
      cat.assign_attributes(ncm_code: attrs[:ncm_code], ncm_description: attrs[:ncm_description])
      if cat.save
        Rails.logger.debug "[seeds] Categoria: #{cat.name} (#{cat.ncm_code})"
      else
        Rails.logger.error "[seeds] Falha ao salvar #{cat.name}: #{cat.errors.full_messages.join(', ')}"
      end
    end
  end

  Rails.logger.debug "[seeds/celulares_categories] #{CELULARES_CATEGORIES.size} categorias sincronizadas."
end
