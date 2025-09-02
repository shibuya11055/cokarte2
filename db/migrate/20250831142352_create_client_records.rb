class CreateClientRecords < ActiveRecord::Migration[8.0]
  def change
    create_table :client_records, id: :bigint do |t|
      t.references :client, null: false, foreign_key: true
      t.datetime :visited_at
      t.text :note
      t.integer :amount

      t.timestamps
    end
  end
end
