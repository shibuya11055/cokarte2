require 'rails_helper'

RSpec.describe '二要素認証のログインフロー', type: :request do
  it '2FA必須ユーザーはログイン時にチャレンジへリダイレクトされ、正しいコードでログインできる' do
    user = User.create!(first_name: 'U', last_name: 'A', email: '2fa@example.com', password: 'Password1!', confirmed_at: Time.current, tos_accepted_at: Time.current, otp_required_for_login: true)
    user.ensure_otp_secret!

    # まずはログインPOSTでチャレンジへ
    post user_session_path, params: { user: { email: user.email, password: 'Password1!' } }
    expect(response).to redirect_to(two_factor_challenge_path)

    # チャレンジで正しいコードを入力
    totp = ROTP::TOTP.new(user.otp_secret, issuer: 'cokarte')
    code = totp.now
    post two_factor_verify_path, params: { otp_code: code }
    expect(response).to redirect_to(clients_path)
  end

  it '誤ったコードなら401で再表示される' do
    user = User.create!(first_name: 'U', last_name: 'A', email: '2fa2@example.com', password: 'Password1!', confirmed_at: Time.current, tos_accepted_at: Time.current, otp_required_for_login: true)
    user.ensure_otp_secret!
    post user_session_path, params: { user: { email: user.email, password: 'Password1!' } }
    expect(response).to redirect_to(two_factor_challenge_path)

    post two_factor_verify_path, params: { otp_code: '000000' }
    expect(response.status).to eq 401
    expect(response.body).to include('ワンタイムコードが正しくありません')
  end
end

