class User < ApplicationRecord
  include PlanQuota
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable, :trackable and :omniauthable
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :validatable, :confirmable

  has_many :clients

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
end
