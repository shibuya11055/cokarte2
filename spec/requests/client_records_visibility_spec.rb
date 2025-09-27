require 'rails_helper'

RSpec.describe 'カルテデータの可視性', type: :request do
  def create_user(email)
    User.create!(first_name: 'U', last_name: 'A', email: email, password: 'Password1!', confirmed_at: Time.current, tos_accepted_at: Time.current)
  end

  it 'カルテ一覧に他ユーザーのカルテは表示されない' do
    user_a = create_user('ra@example.com')
    user_b = create_user('rb@example.com')
    ca = Client.create!(user_id: user_a.id, first_name: 'A', last_name: '顧客A', birthday: '1990-01-01')
    cb = Client.create!(user_id: user_b.id, first_name: 'B', last_name: '顧客B', birthday: '1992-02-02')
    ClientRecord.create!(client: ca, visited_at: Time.current, amount: 1000)
    ClientRecord.create!(client: cb, visited_at: Time.current, amount: 2000)

    login_as user_a, scope: :user
    get client_records_path
    expect(response).to have_http_status(:ok)
    expect(response.body).to include('顧客A')
    expect(response.body).not_to include('顧客B')
  end

  it '他ユーザーのカルテ詳細・編集は404になる' do
    user_a = create_user('ra2@example.com')
    user_b = create_user('rb2@example.com')
    ca = Client.create!(user_id: user_a.id, first_name: 'A', last_name: '顧客A2', birthday: '1990-01-01')
    cb = Client.create!(user_id: user_b.id, first_name: 'B', last_name: '顧客B2', birthday: '1992-02-02')
    own_record = ClientRecord.create!(client: ca, visited_at: Time.current, amount: 1500)
    other_record = ClientRecord.create!(client: cb, visited_at: Time.current, amount: 2500)

    login_as user_a, scope: :user
    get client_record_path(own_record)
    expect(response).to have_http_status(:ok)

    get client_record_path(other_record)
    expect(response.status).to eq 404

    get edit_client_record_path(other_record)
    expect(response.status).to eq 404
  end
end
