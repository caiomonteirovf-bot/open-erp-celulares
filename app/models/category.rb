# frozen_string_literal: true

# == Schema Information
#
# Table name: categories
#
#  id              :bigint           not null, primary key
#  name            :string
#  ncm_code        :string(10)
#  ncm_description :string
#  created_at      :datetime         not null
#  updated_at      :datetime         not null
#  account_id      :integer
#
# Indexes
#
#  index_categories_on_account_id  (account_id)
#
class Category < ApplicationRecord
  NCM_FORMAT = /\A\d{4}\.\d{2}\.\d{2}\z/

  has_many :products
  acts_as_tenant :account

  validates :name, presence: true
  validates :ncm_code,
            format: { with: NCM_FORMAT, message: :invalid_ncm },
            allow_nil: true,
            allow_blank: true
end
