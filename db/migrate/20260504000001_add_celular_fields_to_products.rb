# frozen_string_literal: true

class AddCelularFieldsToProducts < ActiveRecord::Migration[7.0]
  def change
    add_column :products, :imei1,          :string
    add_column :products, :imei2,          :string
    add_column :products, :serial_number,  :string
    add_column :products, :brand,          :string
    add_column :products, :model_name,     :string
    add_column :products, :storage_gb,     :integer
    add_column :products, :ram_gb,         :integer
    add_column :products, :color,          :string
    add_column :products, :condition,      :string
    add_column :products, :battery_health, :integer

    add_index :products, :imei1,         unique: true, where: "imei1 IS NOT NULL"
    add_index :products, :imei2,         unique: true, where: "imei2 IS NOT NULL"
    add_index :products, :serial_number, unique: true, where: "serial_number IS NOT NULL"
  end
end
