# frozen_string_literal: true

# Adiciona código NCM e descrição à tabela de categorias.
# Permite configurar a tributação fiscal correta por categoria de produto.
class AddNcmToCategories < ActiveRecord::Migration[7.0]
  def change
    add_column :categories, :ncm_code,        :string, limit: 10
    add_column :categories, :ncm_description, :string
  end
end
