# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Product, type: :model do
  describe 'campos de celular' do
    subject(:product) { build(:product) }

    describe 'VALID_CONDITIONS' do
      it 'lista as quatro condições aceitas' do
        expect(described_class::VALID_CONDITIONS).to contain_exactly('novo', 'seminovo', 'usado', 'vitrine')
      end
    end

    describe 'condition' do
      it 'aceita valor nil' do
        product.condition = nil
        expect(product).to be_valid
      end

      described_class::VALID_CONDITIONS.each do |cond|
        it "aceita condição '#{cond}'" do
          product.condition = cond
          expect(product).to be_valid
        end
      end

      it 'rejeita condição desconhecida' do
        product.condition = 'recondicionado'
        expect(product).not_to be_valid
        expect(product.errors[:condition]).to be_present
      end
    end

    describe 'battery_health' do
      it 'aceita valor nil' do
        product.battery_health = nil
        expect(product).to be_valid
      end

      it 'aceita 1 (mínimo)' do
        product.battery_health = 1
        expect(product).to be_valid
      end

      it 'aceita 100 (máximo)' do
        product.battery_health = 100
        expect(product).to be_valid
      end

      it 'rejeita 0' do
        product.battery_health = 0
        expect(product).not_to be_valid
      end

      it 'rejeita 101' do
        product.battery_health = 101
        expect(product).not_to be_valid
      end

      it 'rejeita valor decimal' do
        product.battery_health = 85.5
        expect(product).not_to be_valid
      end
    end

    describe 'imei1' do
      it 'aceita nil' do
        product.imei1 = nil
        expect(product).to be_valid
      end

      it 'aceita string vazia' do
        product.imei1 = ''
        expect(product).to be_valid
      end

      it 'aceita 15 dígitos numéricos' do
        product.imei1 = '356938035643809'
        expect(product).to be_valid
      end

      it 'rejeita IMEI com 14 dígitos' do
        product.imei1 = '35693803564380'
        expect(product).not_to be_valid
      end

      it 'rejeita IMEI com 16 dígitos' do
        product.imei1 = '3569380356438091'
        expect(product).not_to be_valid
      end

      it 'rejeita IMEI com letras' do
        product.imei1 = '35693803564380X'
        expect(product).not_to be_valid
      end
    end

    describe 'imei2' do
      it 'aceita nil (aparelho single SIM)' do
        product.imei2 = nil
        expect(product).to be_valid
      end

      it 'aceita 15 dígitos' do
        product.imei2 = '490154203237518'
        expect(product).to be_valid
      end

      it 'rejeita formato inválido' do
        product.imei2 = 'ABC123'
        expect(product).not_to be_valid
      end
    end

    describe 'colunas no banco' do
      it { is_expected.to have_db_column(:imei1).of_type(:string) }
      it { is_expected.to have_db_column(:imei2).of_type(:string) }
      it { is_expected.to have_db_column(:serial_number).of_type(:string) }
      it { is_expected.to have_db_column(:brand).of_type(:string) }
      it { is_expected.to have_db_column(:model_name).of_type(:string) }
      it { is_expected.to have_db_column(:storage_gb).of_type(:integer) }
      it { is_expected.to have_db_column(:ram_gb).of_type(:integer) }
      it { is_expected.to have_db_column(:color).of_type(:string) }
      it { is_expected.to have_db_column(:condition).of_type(:string) }
      it { is_expected.to have_db_column(:battery_health).of_type(:integer) }
    end

    describe 'persiste todos os campos de celular' do
      include_context 'when user account'

      it 'salva e recarrega corretamente' do
        saved = create(:product,
                       imei1: '356938035643809',
                       imei2: nil,
                       serial_number: 'SN123ABC',
                       brand: 'Samsung',
                       model_name: 'Galaxy S23',
                       storage_gb: 128,
                       ram_gb: 8,
                       color: 'Preto',
                       condition: 'seminovo',
                       battery_health: 87,
                       account_id: user.account.id)

        reloaded = described_class.find(saved.id)
        expect(reloaded.imei1).to eq('356938035643809')
        expect(reloaded.brand).to eq('Samsung')
        expect(reloaded.model_name).to eq('Galaxy S23')
        expect(reloaded.storage_gb).to eq(128)
        expect(reloaded.ram_gb).to eq(8)
        expect(reloaded.color).to eq('Preto')
        expect(reloaded.condition).to eq('seminovo')
        expect(reloaded.battery_health).to eq(87)
        expect(reloaded.serial_number).to eq('SN123ABC')
      end
    end
  end
end
