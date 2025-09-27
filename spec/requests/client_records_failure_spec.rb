require 'rails_helper'

RSpec.describe 'カルテCRUDの失敗系', type: :request do
  def create_user(email: 'failr@example.com')
    create(:user, email: email)
  end

  it '登録: client_idなしは422になる' do
    user = create_user(email: 'failr1@example.com')
    login_as user, scope: :user

    expect {
      post client_records_path, params: { client_record: { visited_at: Time.current, note: 'n' } }
    }.not_to change { ClientRecord.count }

    expect(response.status).to eq 422
    expect(response.body).to include('エラー').or include('error').or include('unprocessable')
  end

  it '登録: 存在しないclient_idは422になる' do
    user = create_user(email: 'failr2@example.com')
    login_as user, scope: :user

    expect {
      post client_records_path, params: { client_record: { client_id: -1, visited_at: Time.current, note: 'n' } }
    }.not_to change { ClientRecord.count }

    expect(response.status).to eq 422
  end
end
