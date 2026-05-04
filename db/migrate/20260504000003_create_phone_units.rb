# frozen_string_literal: true

class CreatePhoneUnits < ActiveRecord::Migration[7.0]
  def change
    create_table :phone_units do |t|
      t.references :product,  null: false, foreign_key: true
      t.integer    :account_id, null: false
      t.string     :imei1,        null: false
      t.string     :imei2
      t.string     :serial_number
      t.string     :status,       null: false, default: 'em_estoque'
      t.string     :condition
      t.decimal    :purchase_price, precision: 10, scale: 2
      t.decimal    :sale_price,     precision: 10, scale: 2
      t.integer    :battery_health
      t.string     :color
      t.text       :notes

      t.timestamps
    end

    add_index :phone_units, :imei1,         unique: true
    add_index :phone_units, :imei2,         unique: true, where: "imei2 IS NOT NULL AND imei2 != ''"
    add_index :phone_units, :serial_number, unique: true, where: "serial_number IS NOT NULL AND serial_number != ''"
    add_index :phone_units, :account_id
    add_index :phone_units, :status
  end
end
