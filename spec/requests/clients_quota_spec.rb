require 'rails_helper'

RSpec.describe "顧客数クォータ", type: :request do
  def create_user(plan: 'free', count: 0)
    User.create!(first_name: 'Test', last_name: 'User', email: "#{plan}-user@example.com", password: 'Password1!', confirmed_at: Time.current, plan_tier: plan, clients_count: count)
  end

  it 'Freeプランで上限(50件)到達時は作成をブロックする' do
    user = create_user(plan: 'free', count: 50)
    login_as user, scope: :user

    expect {
      post clients_path, params: { client: { first_name: '太郎', last_name: '山田', birthday: '1990-01-01' } }
    }.not_to change { Client.where(user_id: user.id).count }
    expect(response).to redirect_to(clients_path)
  end

  it '上限未満であれば作成できる' do
    user = create_user(plan: 'free', count: 49)
    login_as user, scope: :user

    expect {
      post clients_path, params: { client: { first_name: '太郎', last_name: '山田', birthday: '1990-01-01' } }
    }.to change { Client.where(user_id: user.id).count }.by(1)
  end
end
