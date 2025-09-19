# frozen_string_literal: true

class AddPlanAndClientsCountToUsers < ActiveRecord::Migration[8.0]
  def up
    add_column :users, :plan_tier, :string, null: false, default: "free"
    add_column :users, :clients_count, :integer, null: false, default: 0

    # Backfill clients_count for existing users
    execute <<~SQL
      UPDATE users
      SET clients_count = sub.cnt
      FROM (
        SELECT user_id, COUNT(*) AS cnt
        FROM clients
        GROUP BY user_id
      ) AS sub
      WHERE users.id = sub.user_id;
    SQL
  end

  def down
    remove_column :users, :clients_count
    remove_column :users, :plan_tier
  end
end
