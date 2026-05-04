# frozen_string_literal: true

require 'rails_helper'

RSpec.describe PhoneUnit, type: :model do
  subject(:unit) { build(:phone_unit) }

  describe 'associações' do
    it { is_expected.to belong_to(:product) }
  end

  describe 'colunas no banco' do
    it { is_expected.to have_db_column(:imei1).of_type(:string) }
    it { is_expected.to have_db_column(:imei2).of_type(:string) }
    it { is_expected.to have_db_column(:serial_number).of_type(:string) }
    it { is_expected.to have_db_column(:status).of_type(:string) }
    it { is_expected.to have_db_column(:condition).of_type(:string) }
    it { is_expected.to have_db_column(:purchase_price).of_type(:decimal) }
    it { is_expected.to have_db_column(:sale_price).of_type(:decimal) }
    it { is_expected.to have_db_column(:battery_health).of_type(:integer) }
    it { is_expected.to have_db_column(:color).of_type(:string) }
    it { is_expected.to have_db_column(:notes).of_type(:text) }
  end

  describe 'VALID_STATUSES' do
    it 'lista os 5 status' do
      expect(described_class::VALID_STATUSES).to contain_exactly(
        'em_estoque', 'vendido', 'em_servico', 'devolvido', 'perdido'
      )
    end
  end

  describe 'validações de imei1' do
    it 'exige presença' do
      unit.imei1 = nil
      expect(unit).not_to be_valid
      expect(unit.errors[:imei1]).to be_present
    end

    it 'aceita 15 dígitos' do
      unit.imei1 = '356938035643809'
      expect(unit).to be_valid
    end

    it 'rejeita 14 dígitos' do
      unit.imei1 = '35693803564380'
      expect(unit).not_to be_valid
    end

    it 'rejeita 16 dígitos' do
      unit.imei1 = '3569380356438091'
      expect(unit).not_to be_valid
    end

    it 'rejeita letras' do
      unit.imei1 = '35693803564380X'
      expect(unit).not_to be_valid
    end
  end

  describe 'validações de imei2' do
    it 'aceita nil (single SIM)' do
      unit.imei2 = nil
      expect(unit).to be_valid
    end

    it 'aceita string vazia' do
      unit.imei2 = ''
      expect(unit).to be_valid
    end

    it 'aceita 15 dígitos' do
      unit.imei2 = '490154203237518'
      expect(unit).to be_valid
    end

    it 'rejeita formato inválido' do
      unit.imei2 = 'ABC123'
      expect(unit).not_to be_valid
    end
  end

  describe 'unicidade de IMEI' do
    include_context 'when user account'

    it 'rejeita imei1 duplicado' do
      create(:phone_unit, imei1: '356938035643809', account_id: user.account.id)
      duplicate = build(:phone_unit, imei1: '356938035643809', account_id: user.account.id)
      expect(duplicate).not_to be_valid
      expect(duplicate.errors[:imei1]).to be_present
    end
  end

  describe 'validações de status' do
    it 'exige presença' do
      unit.status = nil
      expect(unit).not_to be_valid
    end

    described_class::VALID_STATUSES.each do |s|
      it "aceita '#{s}'" do
        unit.status = s
        expect(unit).to be_valid
      end
    end

    it 'rejeita status desconhecido' do
      unit.status = 'disponivel'
      expect(unit).not_to be_valid
    end
  end

  describe 'validações de battery_health' do
    it 'aceita nil' do
      unit.battery_health = nil
      expect(unit).to be_valid
    end

    it 'aceita 1 a 100' do
      unit.battery_health = 85
      expect(unit).to be_valid
    end

    it 'rejeita 0' do
      unit.battery_health = 0
      expect(unit).not_to be_valid
    end

    it 'rejeita 101' do
      unit.battery_health = 101
      expect(unit).not_to be_valid
    end
  end

  describe 'scopes' do
    include_context 'when user account'

    let!(:em_estoque) { create(:phone_unit, status: 'em_estoque', account_id: user.account.id) }
    let!(:vendido)    { create(:phone_unit, status: 'vendido',    account_id: user.account.id) }

    it '.em_estoque retorna só unidades em estoque' do
      expect(PhoneUnit.em_estoque).to include(em_estoque)
      expect(PhoneUnit.em_estoque).not_to include(vendido)
    end

    it '.vendidos retorna só vendidos' do
      expect(PhoneUnit.vendidos).to include(vendido)
      expect(PhoneUnit.vendidos).not_to include(em_estoque)
    end

    it '.by_imei filtra por parte do IMEI' do
      result = PhoneUnit.by_imei(em_estoque.imei1[0..9])
      expect(result).to include(em_estoque)
    end
  end

  describe '#vender!' do
    include_context 'when user account'

    it 'muda status para vendido' do
      saved = create(:phone_unit, status: 'em_estoque', account_id: user.account.id)
      saved.vender!
      expect(saved.reload.status).to eq('vendido')
    end
  end

  describe '#devolver!' do
    include_context 'when user account'

    it 'muda status para devolvido' do
      saved = create(:phone_unit, status: 'vendido', account_id: user.account.id)
      saved.devolver!
      expect(saved.reload.status).to eq('devolvido')
    end
  end
end
