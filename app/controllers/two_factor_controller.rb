class TwoFactorController < ApplicationController
  before_action :authenticate_user!, except: [:challenge, :verify]

  # ログイン時の2FAコード入力
  def challenge
    @user = User.find_by(id: session[:otp_user_id])
    return redirect_to new_user_session_path, alert: 'セッションが無効です' unless @user
  end

  def verify
    @user = User.find_by(id: session[:otp_user_id])
    return redirect_to new_user_session_path, alert: 'セッションが無効です' unless @user

    if @user.valid_otp?(params[:otp_code])
      session.delete(:otp_user_id)
      sign_in(:user, @user)
      redirect_to after_sign_in_path_for(@user), notice: 'ログインしました'
    else
      flash.now[:alert] = 'ワンタイムコードが正しくありません'
      render :challenge, status: :unauthorized
    end
  end

  # 設定: 有効化
  def setup
    current_user.ensure_otp_secret!
  end

  def enable
    if current_user.valid_otp?(params[:otp_code])
      current_user.update!(otp_required_for_login: true)
      redirect_to user_profile_path, notice: '二要素認証を有効化しました'
    else
      flash.now[:alert] = 'ワンタイムコードが正しくありません'
      render :setup, status: :unprocessable_entity
    end
  end

  # 無効化
  def disable_form
    # 単にフォームを表示
    render :disable
  end

  def disable
    unless current_user.valid_password?(params[:current_password].to_s)
      flash.now[:alert] = 'パスワードが正しくありません'
      return render :disable, status: :unprocessable_entity
    end
    current_user.update!(otp_required_for_login: false, otp_secret: nil)
    redirect_to user_profile_path, notice: '二要素認証を無効化しました'
  end
end
