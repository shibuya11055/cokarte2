require 'rails_helper'

RSpec.describe '認証要件', type: :request do
  it '未ログインでは顧客一覧にアクセスできずログインへ誘導される' do
    get clients_path
    expect(response).to redirect_to(new_user_session_path)
  end

  it '未ログインではカルテ一覧もログインへ誘導される' do
    get client_records_path
    expect(response).to redirect_to(new_user_session_path)
  end

  it 'ユーザー情報ページもログイン必須' do
    get user_profile_path
    expect(response).to redirect_to(new_user_session_path)
  end
end

