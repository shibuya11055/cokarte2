class Billing::CheckoutsController < ApplicationController
  before_action :authenticate_user!

  def create
    plan = params[:plan].to_s
    price_id = StripePrice.plan_to_price_id(plan)
    return redirect_to pricing_path, alert: 'プランが不正です' if price_id.blank?

    success_url = File.join(ENV.fetch('APP_BASE_URL', root_url), 'user')
    cancel_url  = File.join(ENV.fetch('APP_BASE_URL', root_url), 'pricing')

    customer_id = current_user.stripe_customer_id.presence

    session = Stripe::Checkout::Session.create(
      mode: 'subscription',
      line_items: [{ price: price_id, quantity: 1 }],
      success_url: success_url,
      cancel_url: cancel_url,
      customer: customer_id,
      client_reference_id: (customer_id ? nil : current_user.id),
      allow_promotion_codes: true,
      consent_collection: { terms_of_service: 'required', privacy_policy: 'required' }
    )

    redirect_to session.url, allow_other_host: true
  rescue Stripe::StripeError => e
    redirect_to pricing_path, alert: "決済の開始に失敗しました: #{e.message}"
  end
end
