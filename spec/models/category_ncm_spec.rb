# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Category, type: :model do
  describe 'campos NCM' do
    subject(:category) { build(:category) }

    describe 'NCM_FORMAT' do
      it 'valida o padrão 0000.00.00' do
        expect(described_class::NCM_FORMAT).to match('8517.13.00')
        expect(described_class::NCM_FORMAT).not_to match('851713')
        expect(described_class::NCM_FORMAT).not_to match('8517.1300')
      end
    end

    describe 'ncm_code' do
      it 'aceita nil' do
        category.ncm_code = nil
        expect(category).to be_valid
      end

      it 'aceita string vazia' do
        category.ncm_code = ''
        expect(category).to be_valid
      end

      it 'aceita formato correto' do
        category.ncm_code = '8517.13.00'
        expect(category).to be_valid
      end

      it 'rejeita formato sem pontos' do
        category.ncm_code = '85171300'
        expect(category).not_to be_valid
        expect(category.errors[:ncm_code]).to be_present
      end

      it 'rejeita formato parcialmente pontuado' do
        category.ncm_code = '8517.1300'
        expect(category).not_to be_valid
      end
    end

    describe 'colunas no banco' do
      it { is_expected.to have_db_column(:ncm_code).of_type(:string) }
      it { is_expected.to have_db_column(:ncm_description).of_type(:string) }
    end
  end
end
