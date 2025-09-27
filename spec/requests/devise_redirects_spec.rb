require 'rails_helper'

RSpec.describe '認証ページの挙動', type: :request do
  it 'ログイン済みでログインページを開くと/clientsへ' do
    user = User.create!(first_name: 'U', last_name: 'A', email: 'redir@example.com', password: 'Password1!', confirmed_at: Time.current, tos_accepted_at: Time.current)
    login_as user, scope: :user
    get new_user_session_path
    expect(response).to redirect_to(clients_path)
  end

  it '未ログインでLP/法務系は200' do
    get root_path
    expect(response).to have_http_status(:ok)
    get legal_path
    expect(response).to have_http_status(:ok)
    get privacy_path
    expect(response).to have_http_status(:ok)
    get terms_path
    expect(response).to have_http_status(:ok)
  end
end

