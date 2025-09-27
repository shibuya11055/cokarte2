require 'rails_helper'

RSpec.describe 'Stripe成功パス', type: :request do
  it 'Checkout: 有効なプランならStripeへリダイレクト（スタブ）' do
    user = create(:user)
    login_as user, scope: :user

    allow(Stripe::Checkout::Session).to receive(:create).and_return(double(url: 'https://stripe.example/session'))
    allow(ENV).to receive(:[]).and_call_original
    allow(ENV).to receive(:[]).with('STRIPE_PRICE_BASIC').and_return('price_basic')

    post billing_checkout_path, params: { plan: 'basic' }
    expect(response).to redirect_to('https://stripe.example/session')
  end

  it 'Portal: 顧客IDがあればStripeポータルへリダイレクト（スタブ）' do
    user = create(:user, stripe_customer_id: 'cus_123')
    login_as user, scope: :user

    allow(Stripe::BillingPortal::Session).to receive(:create).and_return(double(url: 'https://stripe.example/portal'))
    post billing_portal_path
    expect(response).to redirect_to('https://stripe.example/portal')
  end
end

