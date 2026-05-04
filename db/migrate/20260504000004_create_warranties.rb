# frozen_string_literal: true

class CreateWarranties < ActiveRecord::Migration[7.0]
  def change
    create_table :warranties do |t|
      t.references :phone_unit, null: false, foreign_key: true
      t.integer    :account_id, null: false
      t.string     :warranty_type, null: false
      t.date       :started_at,   null: false
      t.date       :expires_at,   null: false
      t.text       :notes
      t.string     :document_number

      t.timestamps
    end

    add_index :warranties, :account_id
    add_index :warranties, :expires_at
    add_index :warranties, :warranty_type
  end
end
