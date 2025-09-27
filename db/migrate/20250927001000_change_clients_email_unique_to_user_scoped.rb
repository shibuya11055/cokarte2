class ChangeClientsEmailUniqueToUserScoped < ActiveRecord::Migration[8.0]
  disable_ddl_transaction!

  def up
    # 旧インデックスを削除（存在すれば）
    %w[index_clients_on_email_not_blank index_clients_on_email index_clients_on_user_id_and_email_not_blank].each do |idx|
      remove_index :clients, name: idx, algorithm: :concurrently if index_name_exists?(:clients, idx)
    end

    # user_id + email の複合ユニーク（部分条件なし）
    add_index :clients, [ :user_id, :email ], unique: true,
              name: 'index_clients_on_user_id_and_email', algorithm: :concurrently
  end

  def down
    if index_name_exists?(:clients, 'index_clients_on_user_id_and_email')
      remove_index :clients, name: 'index_clients_on_user_id_and_email', algorithm: :concurrently
    end
    # 旧構成（メール単独ユニーク）へ戻す
    add_index :clients, :email, unique: true, name: 'index_clients_on_email', algorithm: :concurrently
  end
end
