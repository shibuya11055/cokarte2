class Users::RegistrationsController < Devise::RegistrationsController
  # 同意チェックに合わせてタイムスタンプを保存
  def build_resource(hash = {})
    super
    if params.dig(:user, :tos_agree) == '1'
      resource.tos_accepted_at = Time.current
    end
  end

  def destroy
    if current_user&.require_subscription_cancellation_before_destroy?
      redirect_to edit_user_registration_path,
                  alert: "有料プランをご利用中です。先に Customer Portal で解約を完了してください。"
      return
    end

    super
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
