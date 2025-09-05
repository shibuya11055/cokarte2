# == Schema Information
#
# Table name: client_records
#
#  id         :integer          not null, primary key
#  client_id  :integer          not null
#  visited_at :datetime
#  note       :text
#  amount     :integer
#  created_at :datetime         not null
#  updated_at :datetime         not null
#
# Indexes
#
#  index_client_records_on_client_id  (client_id)
#

class ClientRecord < ApplicationRecord
  belongs_to :client
end
