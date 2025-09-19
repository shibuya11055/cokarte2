# frozen_string_literal: true

class AddTosAcceptedAtToUsers < ActiveRecord::Migration[8.0]
  def change
    add_column :users, :tos_accepted_at, :datetime
  end
end

