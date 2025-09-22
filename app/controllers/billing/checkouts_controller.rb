class Billing::CheckoutsController < ApplicationController
  before_action :authenticate_user!

  def create
    plan = params[:plan].to_s
    price_id = StripePrice.plan_to_price_id(plan)
    return redirect_to pricing_path, alert: "\u30D7\u30E9\u30F3\u304C\u4E0D\u6B63\u3067\u3059" if price_id.blank?

    success_url = File.join(ENV.fetch("APP_BASE_URL", root_url), "user")
    cancel_url  = File.join(ENV.fetch("APP_BASE_URL", root_url), "pricing")

    customer_id = current_user.stripe_customer_id.presence

    args = {
      mode: "subscription",
      line_items: [ { price: price_id, quantity: 1 } ],
      success_url: success_url,
      cancel_url: cancel_url,
      customer: customer_id,
      client_reference_id: (customer_id ? nil : current_user.id),
      allow_promotion_codes: true
    }
    # 同意は本番のみ（ダッシュボードのURLは本番ドメインで設定）
    if Rails.env.production?
      # Checkout の consent_collection は terms_of_service のみ対応
      args[:consent_collection] = { terms_of_service: "required" }
    end

    session = Stripe::Checkout::Session.create(args)

    redirect_to session.url, allow_other_host: true
  rescue Stripe::StripeError => e
    Rails.logger.error("[Stripe] Checkout error: #{e.class}: #{e.message}")
    redirect_to pricing_path, alert: I18n.t("flash.checkout.failed")
  end
end
