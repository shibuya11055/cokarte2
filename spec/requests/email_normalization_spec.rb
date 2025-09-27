require 'rails_helper'

RSpec.describe 'メール正規化・重複検証', type: :request do
  it '同一ユーザー内で大文字/小文字が異なるだけのメールは重複扱い' do
    user = create(:user, email: 'norm@example.com')
    login_as user, scope: :user
    post clients_path, params: { client: { first_name: 'A', last_name: 'A', birthday: '1990-01-01', email: 'USER@EXAMPLE.COM' } }
    expect(response).to have_http_status(302)
    created = Client.where(user_id: user.id).order(id: :desc).first
    expect(created.email).to eq 'user@example.com'

    patch client_path(created), params: { client: { email: 'user@example.com' } }
    expect(response).to redirect_to(client_path(created))

    post clients_path, params: { client: { first_name: 'B', last_name: 'B', birthday: '1991-01-01', email: 'User@Example.com' } }
    expect(response.status).to eq 422
    expect(response.body).to include('このメールアドレスは既に登録されています')
  end
end
