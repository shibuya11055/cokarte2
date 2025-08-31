class CreateClients < ActiveRecord::Migration[8.0]
  def change
    create_table :clients do |t|
      t.references :user, null: false, foreign_key: true
      t.date      :birthday, null: false, comment: '生年月日'
      t.string    :first_name, null: false, comment: '名'
      t.string    :last_name, null: false, comment: '姓'
      t.string    :postal_code, comment: '郵便番号'
      t.string    :address, comment: '住所'
      t.string    :phone_number, comment: '電話番号'
      t.text      :memo, comment: 'メモ'
      t.string    :email, comment: 'メールアドレス'
      t.timestamps
    end
    add_index :clients, :email, unique: true
  end
end
