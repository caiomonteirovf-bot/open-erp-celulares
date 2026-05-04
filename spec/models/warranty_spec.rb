# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Warranty, type: :model do
  subject(:warranty) { build(:warranty) }

  describe 'associações' do
    it { is_expected.to belong_to(:phone_unit) }
  end

  describe 'colunas no banco' do
    it { is_expected.to have_db_column(:warranty_type).of_type(:string) }
    it { is_expected.to have_db_column(:started_at).of_type(:date) }
    it { is_expected.to have_db_column(:expires_at).of_type(:date) }
    it { is_expected.to have_db_column(:document_number).of_type(:string) }
    it { is_expected.to have_db_column(:notes).of_type(:text) }
  end

  describe 'validações' do
    it { is_expected.to be_valid }
    it { is_expected.to validate_presence_of(:warranty_type) }
    it { is_expected.to validate_presence_of(:started_at) }
    it { is_expected.to validate_presence_of(:expires_at) }

    it 'rejeita tipo desconhecido' do
      warranty.warranty_type = 'extra'
      expect(warranty).not_to be_valid
    end

    it 'rejeita expires_at igual a started_at' do
      warranty.expires_at = warranty.started_at
      expect(warranty).not_to be_valid
      expect(warranty.errors[:expires_at]).to be_present
    end

    it 'rejeita expires_at anterior a started_at' do
      warranty.expires_at = warranty.started_at - 1.day
      expect(warranty).not_to be_valid
    end
  end

  describe '#status' do
    it 'retorna :active para garantia vigente' do
      warranty.expires_at = Date.current + 60.days
      expect(warranty.status).to eq(:active)
    end

    it 'retorna :expiring_soon quando vence em 30 dias ou menos' do
      warranty.expires_at = Date.current + 15.days
      expect(warranty.status).to eq(:expiring_soon)
    end

    it 'retorna :expired quando vencida' do
      warranty.expires_at = Date.current - 1.day
      warranty.started_at = Date.current - 2.days
      expect(warranty.status).to eq(:expired)
    end
  end

  describe '#days_remaining' do
    it 'retorna positivo para garantia ativa' do
      warranty.expires_at = Date.current + 30.days
      expect(warranty.days_remaining).to eq(30)
    end

    it 'retorna negativo para garantia vencida' do
      warranty.expires_at = Date.current - 5.days
      warranty.started_at = Date.current - 10.days
      expect(warranty.days_remaining).to eq(-5)
    end
  end

  describe 'scopes' do
    include_context 'when user account'

    let!(:ativa)          { create(:warranty, expires_at: Date.current + 60.days, account_id: user.account.id) }
    let!(:vence_breve)    { create(:warranty, :expiring_soon, account_id: user.account.id) }
    let!(:vencida)        { create(:warranty, :expired, account_id: user.account.id) }

    it '.active não inclui vencidas' do
      expect(Warranty.active).to include(ativa, vence_breve)
      expect(Warranty.active).not_to include(vencida)
    end

    it '.expired inclui apenas vencidas' do
      expect(Warranty.expired).to include(vencida)
      expect(Warranty.expired).not_to include(ativa)
    end

    it '.expiring_soon inclui somente as que vencem em até 30 dias' do
      expect(Warranty.expiring_soon).to include(vence_breve)
      expect(Warranty.expiring_soon).not_to include(ativa)
      expect(Warranty.expiring_soon).not_to include(vencida)
    end
  end
end
