class Users::RegistrationsController < Devise::RegistrationsController
  # 同意チェックに合わせてタイムスタンプを保存
  def build_resource(hash = {})
    super
    if params.dig(:user, :tos_agree) == '1'
      resource.tos_accepted_at = Time.current
    end
  end

  protected

  # 登録後はログイン画面にリダイレクト
  def after_inactive_sign_up_path_for(resource)
    new_user_session_path
  end

  def show
    @user = current_user
  end
end
