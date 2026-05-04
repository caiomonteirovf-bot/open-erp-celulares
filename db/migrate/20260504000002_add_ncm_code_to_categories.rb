# frozen_string_literal: true

class AddNcmCodeToCategories < ActiveRecord::Migration[7.0]
  def change
    add_column :categories, :ncm_code,        :string, limit: 10
    add_column :categories, :ncm_description, :string
  end
end
