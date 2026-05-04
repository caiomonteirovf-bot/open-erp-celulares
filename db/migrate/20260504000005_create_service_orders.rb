# frozen_string_literal: true

class CreateServiceOrders < ActiveRecord::Migration[7.0]
  def change
    create_table :service_orders do |t|
      t.integer    :account_id,    null: false
      t.references :customer,      null: false, foreign_key: true
      t.references :phone_unit,    null: true,  foreign_key: true
      t.string     :status,        null: false, default: 'aberta'
      t.string     :reported_defect, null: false
      t.text       :diagnosis
      t.text       :technician_notes
      t.decimal    :labor_cost,    precision: 10, scale: 2, default: 0
      t.decimal    :parts_cost,    precision: 10, scale: 2, default: 0
      t.decimal    :total_cost,    precision: 10, scale: 2, default: 0
      t.date       :promised_at
      t.datetime   :closed_at
      t.string     :device_brand
      t.string     :device_model
      t.string     :device_imei
      t.string     :device_color
      t.integer    :device_battery_health
      t.text       :accessories_received
      t.boolean    :under_warranty, default: false

      t.timestamps
    end

    add_index :service_orders, :account_id
    add_index :service_orders, :status
    add_index :service_orders, :customer_id
    add_index :service_orders, :created_at
  end
end
