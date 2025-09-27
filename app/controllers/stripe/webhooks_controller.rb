class Stripe::WebhooksController < ApplicationController
  # WebhookはCSRF/ログイン認証の対象外
  skip_forgery_protection
  skip_before_action :authenticate_user!

  def create
    payload = request.body.read
    sig = request.env['HTTP_STRIPE_SIGNATURE']
    secret = ENV['STRIPE_WEBHOOK_SECRET']

    event = if Rails.env.test?
              # テストは署名検証をスキップして形だけのイベントを構築
              Stripe::Event.construct_from(JSON.parse(payload, symbolize_names: true))
            elsif secret.present?
              Stripe::Webhook.construct_event(payload, sig, secret)
            else
              Stripe::Event.construct_from(JSON.parse(payload, symbolize_names: true))
            end

    case event.type
    when 'checkout.session.completed'
      on_checkout_completed(event.data.object)
    when 'customer.subscription.created', 'customer.subscription.updated'
      on_subscription_updated(event.data.object)
    when 'customer.subscription.deleted'
      on_subscription_deleted(event.data.object)
    end

    head :ok
  rescue JSON::ParserError, Stripe::SignatureVerificationError
    head :bad_request
  end

  private

  def on_checkout_completed(session)
    user = find_user_from_session(session)
    return unless user
    customer_id = session.customer
    user.update!(stripe_customer_id: customer_id) if customer_id.present? && user.stripe_customer_id.blank?

    # Checkout完了直後に購読が付与されている場合は、その場で購読情報を取り込み
    if session.respond_to?(:subscription) && session.subscription.present?
      begin
        subscription = Stripe::Subscription.retrieve(session.subscription)
        on_subscription_updated(subscription)
      rescue Stripe::StripeError
        # 購読取得に失敗しても致命的ではない（後続のsubscription.updatedで反映される）
      end
    end
  end

  def on_subscription_updated(sub)
    user = User.find_by(stripe_customer_id: sub.customer)
    return unless user

    plan = plan_from_subscription(sub)
    status = sub.status
    attrs = { subscription_status: status }
    attrs[:plan_tier] = plan if plan
    user.update!(attrs)
  end

  def on_subscription_deleted(sub)
    user = User.find_by(stripe_customer_id: sub.customer)
    return unless user
    user.update!(plan_tier: 'free', subscription_status: 'canceled')
  end

  def plan_from_subscription(sub)
    item = sub.items && sub.items.data.first
    price_id = item&.price&.id
    return 'basic' if price_id.present? && price_id == ENV['STRIPE_PRICE_BASIC']
    return 'pro'   if price_id.present? && price_id == ENV['STRIPE_PRICE_PRO']
    nil
  end

  def find_user_from_session(session)
    if session.client_reference_id
      User.find_by(id: session.client_reference_id)
    elsif session.customer
      User.find_by(stripe_customer_id: session.customer)
    end
  end
end
