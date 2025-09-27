require 'rails_helper'

RSpec.describe '顧客メール重複のスコープ', type: :request do
  def create_user(email)
    User.create!(first_name: 'U', last_name: 'A', email: email, password: 'Password1!', confirmed_at: Time.current, tos_accepted_at: Time.current)
  end

  it '同一ユーザー内ではメールはユニーク' do
    user = create_user('scopea@example.com')
    login_as user, scope: :user
    Client.create!(user_id: user.id, first_name: 'A', last_name: 'A', birthday: '1990-01-01', email: 'dup@example.com')

    post clients_path, params: { client: { first_name: 'B', last_name: 'B', birthday: '1991-01-01', email: 'dup@example.com' } }
    expect(response.status).to eq 422
    expect(response.body).to include('このメールアドレスは既に登録されています')
  end

  it '別ユーザーなら同じメールを使用できる' do
    user1 = create_user('scopeb1@example.com')
    user2 = create_user('scopeb2@example.com')

    login_as user1, scope: :user
    post clients_path, params: { client: { first_name: 'A', last_name: 'A', birthday: '1990-01-01', email: 'same@example.com' } }
    expect(response).to have_http_status(302)
    logout(:user)

    login_as user2, scope: :user
    expect {
      post clients_path, params: { client: { first_name: 'B', last_name: 'B', birthday: '1991-01-01', email: 'same@example.com' } }
    }.to change { Client.where(user_id: user2.id).count }.by(1)
  end
end

