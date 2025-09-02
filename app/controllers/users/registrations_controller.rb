class Users::RegistrationsController < Devise::RegistrationsController
  protected

  # 登録後はログイン画面にリダイレクト
  def after_inactive_sign_up_path_for(resource)
    new_user_session_path
  end

  def show
    @user = current_user
  end
end
