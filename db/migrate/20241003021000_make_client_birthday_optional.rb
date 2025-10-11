class MakeClientBirthdayOptional < ActiveRecord::Migration[8.0]
  def change
    change_column_null :clients, :birthday, true
  end
end
