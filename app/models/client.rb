# == Schema Information
#
# Table name: clients
#
#  id              :integer          not null, primary key
#  user_id         :integer          not null
#  birthday        :date
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
#  index_clients_on_user_id            (user_id)
#  index_clients_on_user_id_and_email  (user_id,email) UNIQUE
#

class Client < ApplicationRecord
  belongs_to :user, counter_cache: true
  has_many :client_records

  # 入力が空の場合はNULLへ、空白や大文字を正規化
  before_validation :normalize_email

  # メールは任意だが、指定された場合のみ一意性を担保（ユーザー内でユニーク）
  validates :email, uniqueness: { allow_blank: true, scope: :user_id }

  private
  def normalize_email
    self.email = email.to_s.strip.downcase.presence
  end
end
