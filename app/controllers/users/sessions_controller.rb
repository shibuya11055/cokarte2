class Users::SessionsController < Devise::SessionsController
  # パスワード認証 → 2FA 必須ならワンタイムコード入力へ誘導
  def create
    self.resource = User.find_for_database_authentication(email: params.dig(:user, :email))
    if resource && resource.valid_password?(params.dig(:user, :password)) && resource.confirmed?
      if resource.otp_required_for_login
        session[:otp_user_id] = resource.id
        redirect_to two_factor_challenge_path and return
      else
        sign_in(resource_name, resource)
        respond_with resource, location: after_sign_in_path_for(resource)
      end
    else
      # デフォルトの処理（失敗）
      flash.now[:alert] = 'メールアドレスまたはパスワードが正しくありません'
      self.resource = resource_class.new(sign_in_params)
      render :new, status: :unauthorized
    end
  end

  protected
  def after_sign_in_path_for(resource)
    root_path
  end
end
