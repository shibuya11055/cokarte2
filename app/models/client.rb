# == Schema Information
#
# Table name: clients
#
#  id              :integer          not null, primary key
#  user_id         :integer          not null
#  birthday        :date             not null
#  first_name      :string           not null
#  last_name       :string           not null
#  postal_code     :string
#  address         :string
#  phone_number    :string
#  memo            :text
#  email           :string
#  created_at      :datetime         not null
#  updated_at      :datetime         not null
#  first_name_kana :string
#  last_name_kana  :string
#
# Indexes
#
#  index_clients_on_email    (email) UNIQUE
#  index_clients_on_user_id  (user_id)
#

class Client < ApplicationRecord
  has_many :client_records
end
