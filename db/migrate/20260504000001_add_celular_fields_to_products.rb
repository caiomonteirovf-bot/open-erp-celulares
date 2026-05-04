# frozen_string_literal: true

# Adiciona campos específicos de celular ao modelo Product.
# Estes campos são opcionais para manter compatibilidade com
# os demais tipos de produto já cadastrados.
class AddCelularFieldsToProducts < ActiveRecord::Migration[7.0]
  def change
    add_column :products, :imei1,          :string,  limit: 15
    add_column :products, :imei2,          :string,  limit: 15
    add_column :products, :serial_number,  :string
    add_column :products, :brand,          :string
    add_column :products, :phone_model,    :string
    add_column :products, :storage_gb,     :integer
    add_column :products, :ram_gb,         :integer
    add_column :products, :color,          :string
    add_column :products, :condition,      :string
    add_column :products, :battery_health, :integer

    # Índices parciais: só garante unicidade quando o campo está preenchido.
    add_index :products, :imei1,
              unique: true,
              where: "imei1 IS NOT NULL AND imei1 != ''",
              name: 'index_products_on_imei1_unique'

    add_index :products, :imei2,
              unique: true,
              where: "imei2 IS NOT NULL AND imei2 != ''",
              name: 'index_products_on_imei2_unique'
  end
end
