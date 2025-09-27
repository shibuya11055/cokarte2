require 'rails_helper'

RSpec.describe 'カルテの作成/更新における所有権チェック', type: :request do
  def create_user(email)
    create(:user, email: email)
  end

  it '他ユーザーのclient_idでは作成できない（404）' do
    user_a = create_user('sec-a@example.com')
    user_b = create_user('sec-b@example.com')
    own_client   = create(:client, user: user_a, first_name: '自分', last_name: 'A')
    other_client = create(:client, user: user_b, first_name: '他人', last_name: 'B')

    login_as user_a, scope: :user
    expect {
      post client_records_path, params: { client_record: { client_id: other_client.id, visited_at: Time.current, note: 'x' } }
    }.not_to change { ClientRecord.count }
    expect(response.status).to eq 404
  end

  it '更新時に他ユーザーのclientへ付け替えできない（404）' do
    user_a = create_user('sec2-a@example.com')
    user_b = create_user('sec2-b@example.com')
    own_client   = create(:client, user: user_a, first_name: '自分', last_name: 'A')
    other_client = create(:client, user: user_b, first_name: '他人', last_name: 'B')
    record = create(:client_record, client: own_client, note: 'n')

    login_as user_a, scope: :user
    patch client_record_path(record), params: { client_record: { client_id: other_client.id, note: 'moved' } }
    expect(response.status).to eq 404
    expect(record.reload.client_id).to eq own_client.id
  end
end
