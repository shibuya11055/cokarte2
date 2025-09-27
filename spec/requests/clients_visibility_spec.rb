require 'rails_helper'

RSpec.describe '顧客データの可視性', type: :request do
  def create_user(email)
    User.create!(first_name: 'U', last_name: 'A', email: email, password: 'Password1!', confirmed_at: Time.current, tos_accepted_at: Time.current)
  end

  it '顧客一覧に他ユーザーの顧客は表示されない' do
    user_a = create_user('a@example.com')
    user_b = create_user('b@example.com')
    Client.create!(user_id: user_a.id, first_name: '太郎', last_name: '山田', birthday: '1990-01-01')
    Client.create!(user_id: user_b.id, first_name: '花子', last_name: '佐藤', birthday: '1992-02-02')

    login_as user_a, scope: :user
    get clients_path
    expect(response).to have_http_status(:ok)
    expect(response.body).to include('山田')
    expect(response.body).not_to include('佐藤')
  end

  it '他ユーザーの顧客詳細は404になる' do
    user_a = create_user('a2@example.com')
    user_b = create_user('b2@example.com')
    own_client = Client.create!(user_id: user_a.id, first_name: '次郎', last_name: '田中', birthday: '1991-03-03')
    other_client = Client.create!(user_id: user_b.id, first_name: '三郎', last_name: '高橋', birthday: '1993-04-04')

    login_as user_a, scope: :user
    get client_path(own_client)
    expect(response).to have_http_status(:ok)

    get client_path(other_client)
    expect(response.status).to eq 404
  end

  it '他ユーザーの顧客編集・更新も404になる' do
    user_a = create_user('a3@example.com')
    user_b = create_user('b3@example.com')
    other_client = Client.create!(user_id: user_b.id, first_name: '四郎', last_name: '中村', birthday: '1994-05-05')

    login_as user_a, scope: :user
    get edit_client_path(other_client)
    expect(response.status).to eq 404

    patch client_path(other_client), params: { client: { first_name: 'X' } }
    expect(response.status).to eq 404
  end
end
