# frozen_string_literal: true

class AddTwoFactorToUsers < ActiveRecord::Migration[8.0]
  def change
    add_column :users, :otp_required_for_login, :boolean, null: false, default: false
    add_column :users, :otp_secret, :string
  end
end

