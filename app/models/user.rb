class User < ApplicationRecord
  include PlanQuota
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable, :trackable and :omniauthable
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :validatable, :confirmable

  has_many :clients, dependent: :destroy

  # 二要素認証（TOTP）
  def ensure_otp_secret!
    return if otp_secret.present?
    self.otp_secret = ROTP::Base32.random_base32
    save!
  end

  def provisioning_uri
    label = CGI.escape(email)
    totp = ROTP::TOTP.new(otp_secret, issuer: 'cokarte')
    totp.provisioning_uri(label)
  end

  def valid_otp?(code)
    return false if otp_secret.blank?
    totp = ROTP::TOTP.new(otp_secret, issuer: 'cokarte')
    totp.verify(code.to_s, drift_behind: 30, drift_ahead: 30)
  end

  def subscription_canceled?
    subscription_status.to_s == "canceled"
  end

  def require_subscription_cancellation_before_destroy?
    stripe_customer_id.present? && (
      plan_tier.to_s != "free" ||
      (subscription_status.present? && !subscription_canceled?)
    )
  end

  # 規約同意（新規登録時に必須）
  validates :tos_accepted_at, presence: { message: 'への同意が必要です' }, on: :create
end
