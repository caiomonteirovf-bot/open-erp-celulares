# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'seeds/celulares_categories' do
  EXPECTED_CATEGORIES = [
    { name: 'Smartphones',        ncm_code: '8517.13.00' },
    { name: 'Fones de Ouvido',    ncm_code: '8518.30.00' },
    { name: 'Carregadores',       ncm_code: '8504.40.40' },
    { name: 'Cabos',              ncm_code: '8544.42.00' },
    { name: 'Power Banks',        ncm_code: '8507.60.00' },
    { name: 'Peças e Componentes', ncm_code: '8517.79.90' },
    { name: 'Películas',          ncm_code: '3919.90.00' },
    { name: 'Capas e Acessórios', ncm_code: '3926.90.90' }
  ].freeze

  include_context 'when user account'

  before do
    ActsAsTenant.with_tenant(user.account) do
      load Rails.root.join('db/seeds/celulares_categories.rb')
    end
  end

  it 'cria exatamente 8 categorias' do
    ActsAsTenant.with_tenant(user.account) do
      expect(Category.count).to eq(8)
    end
  end

  EXPECTED_CATEGORIES.each do |expected|
    it "cria a categoria '#{expected[:name]}' com NCM #{expected[:ncm_code]}" do
      ActsAsTenant.with_tenant(user.account) do
        cat = Category.find_by(name: expected[:name])
        expect(cat).to be_present
        expect(cat.ncm_code).to eq(expected[:ncm_code])
      end
    end
  end

  it 'é idempotente — rodar duas vezes não duplica categorias' do
    ActsAsTenant.with_tenant(user.account) do
      load Rails.root.join('db/seeds/celulares_categories.rb')
      expect(Category.count).to eq(8)
    end
  end

  it 'todos os NCMs passam na validação de formato' do
    ActsAsTenant.with_tenant(user.account) do
      Category.all.each do |cat|
        expect(cat).to be_valid, "#{cat.name} inválida: #{cat.errors.full_messages}"
      end
    end
  end
end
