require 'rails_helper'

RSpec.describe '顧客の登録/編集/削除', type: :request do
  def create_user(email: 'crud@example.com')
    User.create!(first_name: 'U', last_name: 'A', email: email, password: 'Password1!', confirmed_at: Time.current, tos_accepted_at: Time.current)
  end

  it '登録できる（現在のユーザーに紐づく）' do
    user = create_user(email: 'crud1@example.com')
    login_as user, scope: :user

    expect {
      post clients_path, params: { client: { first_name: '太郎', last_name: '山田', birthday: '1990-01-01' } }
    }.to change { Client.where(user_id: user.id).count }.by(1)

    created = Client.where(user_id: user.id).order(id: :desc).first
    expect(response).to redirect_to(client_path(created))
    expect(created.first_name).to eq '太郎'
    expect(created.user_id).to eq user.id
  end

  it '編集できる' do
    user = create_user(email: 'crud2@example.com')
    login_as user, scope: :user
    client = Client.create!(user_id: user.id, first_name: '太郎', last_name: '山田', birthday: '1990-01-01')

    patch client_path(client), params: { client: { first_name: '花子' } }
    expect(response).to redirect_to(client_path(client))
    expect(client.reload.first_name).to eq '花子'
  end

  it '削除できる' do
    user = create_user(email: 'crud3@example.com')
    login_as user, scope: :user
    client = Client.create!(user_id: user.id, first_name: '太郎', last_name: '山田', birthday: '1990-01-01')

    expect {
      delete client_path(client)
    }.to change { Client.where(user_id: user.id).count }.by(-1)
    expect(response).to redirect_to(clients_path)
  end
end

