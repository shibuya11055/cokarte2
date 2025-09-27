require 'rails_helper'

RSpec.describe '二要素認証の設定', type: :request do
  it '有効化: 正しいOTPで有効になる' do
    user = create(:user)
    login_as user, scope: :user
    get two_factor_setup_path
    user.ensure_otp_secret!

    totp = ROTP::TOTP.new(user.otp_secret, issuer: 'cokarte')
    code = totp.now
    post two_factor_enable_path, params: { otp_code: code }
    expect(response).to redirect_to(user_profile_path)
    expect(user.reload.otp_required_for_login).to eq true
  end

  it '無効化: パスワード誤りで422、正しいと無効化される' do
    user = create(:user, otp_required_for_login: true)
    login_as user, scope: :user

    post two_factor_disable_path, params: { current_password: 'wrong' }
    expect(response.status).to eq 422

    post two_factor_disable_path, params: { current_password: 'Password1!' }
    expect(response).to redirect_to(user_profile_path)
    expect(user.reload.otp_required_for_login).to eq false
  end
end

