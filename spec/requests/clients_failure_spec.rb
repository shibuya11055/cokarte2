require 'rails_helper'

RSpec.describe '顧客CRUDの失敗系', type: :request do
  def create_user(email: 'failc@example.com')
    create(:user, email: email)
  end

  it '登録: メールアドレスが重複すると422とフラッシュ表示' do
    user = create_user(email: 'failc1@example.com')
    login_as user, scope: :user
    create(:client, user: user, email: 'dup@example.com')

    expect {
      post clients_path, params: { client: { first_name: '花子', last_name: '佐藤', birthday: '1992-02-02', email: 'dup@example.com' } }
    }.not_to change { Client.where(user_id: user.id).count }

    expect(response.status).to eq 422
    expect(response.body).to include('このメールアドレスは既に登録されています')
  end

  it '編集: 別の自分の顧客とメールが重複すると422とフラッシュ表示' do
    user = create_user(email: 'failc2@example.com')
    login_as user, scope: :user
    a = create(:client, user: user, first_name: 'A', last_name: 'A', email: 'exists@example.com')
    b = create(:client, user: user, first_name: 'B', last_name: 'B', birthday: '1991-01-01')

    patch client_path(b), params: { client: { email: 'exists@example.com' } }
    expect(response.status).to eq 422
    expect(response.body).to include('このメールアドレスは既に登録されています')
  end

  it '削除: 他ユーザーの顧客は404' do
    user_a = create_user(email: 'failc3a@example.com')
    user_b = create_user(email: 'failc3b@example.com')
    other = create(:client, user: user_b, first_name: 'X', last_name: 'Y', birthday: '1992-02-02')

    login_as user_a, scope: :user
    delete client_path(other)
    expect(response.status).to eq 404
  end
end
