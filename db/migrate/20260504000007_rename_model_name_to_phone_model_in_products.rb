# frozen_string_literal: true

# model_name é um método reservado pelo ActiveRecord — renomeia para phone_model.
class RenameModelNameToPhoneModelInProducts < ActiveRecord::Migration[7.0]
  def change
    rename_column :products, :model_name, :phone_model
  end
end
