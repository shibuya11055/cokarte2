# frozen_string_literal: true

class AddKanaToClients < ActiveRecord::Migration[8.0]
  def change
    add_column :clients, :first_name_kana, :string, null: true
    add_column :clients, :last_name_kana, :string, null: true
  end
end

