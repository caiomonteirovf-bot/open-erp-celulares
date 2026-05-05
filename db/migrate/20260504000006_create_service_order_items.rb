# frozen_string_literal: true

class CreateServiceOrderItems < ActiveRecord::Migration[7.0]
  def change
    create_table :service_order_items do |t|
      t.references :service_order, null: false, foreign_key: true
      t.references :product,       null: true,  foreign_key: true
      t.string     :description,   null: false
      t.integer    :quantity,      null: false, default: 1
      t.decimal    :unit_price,    null: false, precision: 10, scale: 2
      t.decimal    :total_price,              precision: 10, scale: 2

      t.timestamps
    end
  end
end
