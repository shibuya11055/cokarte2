class Billing::PortalSessionsController < ApplicationController
  before_action :authenticate_user!

  def create
    customer_id = current_user.stripe_customer_id
    return redirect_to pricing_path, alert: 'ポータルを開くには有料プランの登録が必要です' if customer_id.blank?

    return_url = File.join(ENV.fetch('APP_BASE_URL', root_url), 'user')
    portal = Stripe::BillingPortal::Session.create(customer: customer_id, return_url: return_url)
    redirect_to portal.url, allow_other_host: true
  rescue Stripe::StripeError => e
    redirect_to user_profile_path, alert: "ポータルを開けません: #{e.message}"
  end
end

