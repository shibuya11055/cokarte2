require 'rails_helper'

RSpec.describe '顧客検索', type: :request do
  def user(email)
    create(:user, email: email)
  end

  it '氏名で検索でき、他ユーザーの顧客は含まれない' do
    ua = user('s1@example.com')
    ub = user('s2@example.com')
    c1 = Client.create!(user_id: ua.id, last_name: '山田', first_name: '太郎', birthday: '1990-01-01')
    c2 = Client.create!(user_id: ub.id, last_name: '山田', first_name: '次郎', birthday: '1991-01-01')

    login_as ua, scope: :user
    get clients_path, params: { q: '山田太郎' }
    expect(response).to have_http_status(:ok)
    expect(response.body).to include('山田太郎')
    expect(response.body).not_to include('山田次郎')
  end

  it 'カナで検索できる' do
    ua = user('s3@example.com')
    create(:client, user: ua, last_name: '佐藤', first_name: '花子', last_name_kana: 'サトウ', first_name_kana: 'ハナコ', birthday: '1992-02-02')

    login_as ua, scope: :user
    get clients_path, params: { q: 'サトウハナコ' }
    expect(response).to have_http_status(:ok)
    expect(response.body).to include('佐藤花子')
  end
end
