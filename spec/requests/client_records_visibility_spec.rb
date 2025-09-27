require 'rails_helper'

RSpec.describe 'カルテデータの可視性', type: :request do
  def create_user(email)
    create(:user, email: email)
  end

  it 'カルテ一覧に他ユーザーのカルテは表示されない' do
    user_a = create_user('ra@example.com')
    user_b = create_user('rb@example.com')
    ca = create(:client, user: user_a, last_name: '顧客A', first_name: 'A')
    cb = create(:client, user: user_b, last_name: '顧客B', first_name: 'B')
    create(:client_record, client: ca, amount: 1000)
    create(:client_record, client: cb, amount: 2000)

    login_as user_a, scope: :user
    get client_records_path
    expect(response).to have_http_status(:ok)
    expect(response.body).to include('顧客A')
    expect(response.body).not_to include('顧客B')
  end

  it '他ユーザーのカルテ詳細・編集は404になる' do
    user_a = create_user('ra2@example.com')
    user_b = create_user('rb2@example.com')
    ca = create(:client, user: user_a, last_name: '顧客A2', first_name: 'A')
    cb = create(:client, user: user_b, last_name: '顧客B2', first_name: 'B')
    own_record = create(:client_record, client: ca, amount: 1500)
    other_record = create(:client_record, client: cb, amount: 2500)

    login_as user_a, scope: :user
    get client_record_path(own_record)
    expect(response).to have_http_status(:ok)

    get client_record_path(other_record)
    expect(response.status).to eq 404

    get edit_client_record_path(other_record)
    expect(response.status).to eq 404
  end
end
