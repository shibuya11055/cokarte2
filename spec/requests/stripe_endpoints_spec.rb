require 'rails_helper'

RSpec.describe 'Stripe関連エンドポイント', type: :request do
  it 'CheckoutとPortalはログイン必須' do
    post billing_checkout_path, params: { plan: 'basic' }
    expect(response).to redirect_to(new_user_session_path)

    post billing_portal_path
    expect(response).to redirect_to(new_user_session_path)
  end

  it 'ログイン済み: 不正なプラン指定のCheckoutは料金ページへリダイレクト' do
    user = User.create!(first_name: 'U', last_name: 'A', email: 'st1@example.com', password: 'Password1!', confirmed_at: Time.current, tos_accepted_at: Time.current)
    login_as user, scope: :user
    post billing_checkout_path, params: { plan: 'invalid' }
    expect(response).to redirect_to(pricing_path)
  end

  it 'ログイン済み: Portalは顧客IDが無ければ料金ページへ' do
    user = User.create!(first_name: 'U', last_name: 'A', email: 'st2@example.com', password: 'Password1!', confirmed_at: Time.current, tos_accepted_at: Time.current)
    login_as user, scope: :user
    post billing_portal_path
    expect(response).to redirect_to(pricing_path)
  end

  it 'Webhook: 無効JSONは400、正しいイベントは200' do
    post '/stripe/webhook', params: '{bad json}', headers: { 'CONTENT_TYPE' => 'application/json' }
    expect(response.status).to eq 400

    # 購読削除イベント（署名検証なしでconstruct_from分岐に入る前提）
    u = User.create!(first_name: 'U', last_name: 'A', email: 'st3@example.com', password: 'Password1!', confirmed_at: Time.current, tos_accepted_at: Time.current, stripe_customer_id: 'cus_123')
    payload = {
      type: 'customer.subscription.deleted',
      data: { object: { customer: 'cus_123' } }
    }.to_json
    post '/stripe/webhook', params: payload, headers: { 'CONTENT_TYPE' => 'application/json' }
    expect(response.status).to eq 200
    expect(u.reload.plan_tier).to eq 'free'
    expect(u.subscription_status).to eq 'canceled'
  end
end

