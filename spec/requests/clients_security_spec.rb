require 'rails_helper'

RSpec.describe '顧客のパラメータ改ざん対策', type: :request do
  it '作成時にuser_idを指定しても無視され、current_userに紐づく' do
    me = create(:user, email: 'me@example.com')
    other = create(:user, email: 'other@example.com')
    login_as me, scope: :user

    post clients_path, params: { client: { first_name: '太郎', last_name: '山田', birthday: '1990-01-01', user_id: other.id } }
    expect(response).to have_http_status(302)
    created = Client.order(id: :desc).first
    expect(created.user_id).to eq me.id
  end

  it '更新時にuser_idを書き換えようとしても無視される' do
    me = create(:user, email: 'me2@example.com')
    other = create(:user, email: 'other2@example.com')
    client = create(:client, user: me)
    login_as me, scope: :user

    patch client_path(client), params: { client: { first_name: '花子', user_id: other.id } }
    expect(response).to redirect_to(client_path(client))
    expect(client.reload.user_id).to eq me.id
    expect(client.first_name).to eq '花子'
  end
end

