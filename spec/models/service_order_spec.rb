# frozen_string_literal: true

require 'rails_helper'

RSpec.describe ServiceOrder, type: :model do
  subject(:os) { build(:service_order) }

  describe 'associações' do
    it { is_expected.to belong_to(:customer) }
    it { is_expected.to belong_to(:phone_unit).optional }
    it { is_expected.to have_many(:service_order_items).dependent(:destroy) }
  end

  describe 'colunas no banco' do
    it { is_expected.to have_db_column(:status).of_type(:string) }
    it { is_expected.to have_db_column(:reported_defect).of_type(:string) }
    it { is_expected.to have_db_column(:labor_cost).of_type(:decimal) }
    it { is_expected.to have_db_column(:parts_cost).of_type(:decimal) }
    it { is_expected.to have_db_column(:total_cost).of_type(:decimal) }
    it { is_expected.to have_db_column(:device_imei).of_type(:string) }
  end

  describe 'VALID_STATUSES' do
    it 'lista os 6 status' do
      expect(described_class::VALID_STATUSES).to contain_exactly(
        'aberta', 'em_andamento', 'aguardando_peca', 'pronta', 'entregue', 'cancelada'
      )
    end
  end

  describe 'validações' do
    it { is_expected.to be_valid }
    it { is_expected.to validate_presence_of(:reported_defect) }
    it { is_expected.to validate_presence_of(:status) }

    it 'rejeita status desconhecido' do
      os.status = 'em_espera'
      expect(os).not_to be_valid
    end
  end

  describe '#number' do
    include_context 'when user account'

    it 'formata o número da OS como #OS-00001' do
      saved = create(:service_order, account_id: user.account.id)
      expect(saved.number).to match(/\A#OS-\d{5}\z/)
    end
  end

  describe '#calculate_total (before_save)' do
    include_context 'when user account'

    it 'soma peças + mão de obra no total_cost' do
      saved = create(:service_order, labor_cost: 100, account_id: user.account.id)
      saved.service_order_items.create!(description: 'Tela', quantity: 1, unit_price: 250)
      saved.save!
      expect(saved.reload.total_cost).to eq(350)
    end
  end

  describe 'predicados de status' do
    it '#aberta? retorna true quando aberta' do
      os.status = 'aberta'
      expect(os).to be_aberta
    end

    it '#closed? retorna true para entregue' do
      os.status = 'entregue'
      expect(os).to be_closed
    end

    it '#closed? retorna true para cancelada' do
      os.status = 'cancelada'
      expect(os).to be_closed
    end
  end

  describe 'scopes' do
    include_context 'when user account'

    let!(:aberta)  { create(:service_order, status: 'aberta',   account_id: user.account.id) }
    let!(:pronta)  { create(:service_order, status: 'pronta',   account_id: user.account.id) }
    let!(:entregue){ create(:service_order, status: 'entregue', account_id: user.account.id) }

    it '.abertas filtra corretamente' do
      expect(ServiceOrder.abertas).to include(aberta)
      expect(ServiceOrder.abertas).not_to include(pronta, entregue)
    end

    it '.prontas filtra corretamente' do
      expect(ServiceOrder.prontas).to include(pronta)
    end
  end
end
