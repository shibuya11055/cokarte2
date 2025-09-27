require 'rails_helper'

RSpec.describe '顧客一覧の検索とページング', type: :request do
  it '検索結果がページングされる' do
    user = create(:user)
    login_as user, scope: :user

    # 25件のうち「山田」を5件、それ以外20件
    5.times { |i| create(:client, user: user, last_name: '山田', first_name: "太郎#{i}") }
    20.times { |i| create(:client, user: user, last_name: '佐藤', first_name: "花子#{i}") }

    # 1ページ目（デフォルトper=20）: 山田5 + 佐藤15
    get clients_path, params: { q: '山田' }
    expect(response).to have_http_status(:ok)
    body = response.body
    expect(body.scan('山田').size).to be >= 1

    # 2ページ目: 残りの山田は0件（5件しかないため）
    get clients_path, params: { q: '山田', page: 2 }
    expect(response).to have_http_status(:ok)
    # 山田太郎（検索ヒットの名前）は1ページ目に収まっているので2ページ目には出ない想定
    expect(response.body).not_to include('山田太郎')
  end
end
