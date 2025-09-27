require 'rails_helper'

RSpec.describe 'カルテの登録/編集', type: :request do
  def create_user(email: 'crud-rec@example.com')
    User.create!(first_name: 'U', last_name: 'A', email: email, password: 'Password1!', confirmed_at: Time.current, tos_accepted_at: Time.current)
  end

  it '登録できる（現在のユーザーの顧客に紐づく）' do
    user = create_user(email: 'rec1@example.com')
    login_as user, scope: :user
    client = Client.create!(user_id: user.id, first_name: '太郎', last_name: '山田', birthday: '1990-01-01')

    expect {
      post client_records_path, params: { client_record: { client_id: client.id, visited_at: Time.current, note: '初回', amount: 1200 } }
    }.to change { ClientRecord.joins(:client).where(clients: { user_id: user.id }).count }.by(1)

    expect(response).to redirect_to(client_records_path)
  end

  it '編集できる' do
    user = create_user(email: 'rec2@example.com')
    login_as user, scope: :user
    client = Client.create!(user_id: user.id, first_name: '太郎', last_name: '山田', birthday: '1990-01-01')
    record = ClientRecord.create!(client: client, visited_at: Time.current, note: 'n', amount: 1000)

    patch client_record_path(record), params: { client_record: { note: '更新', amount: 1500 } }
    expect(response).to redirect_to(client_record_path(record))
    expect(record.reload.note).to eq '更新'
    expect(record.amount).to eq 1500
  end
end

