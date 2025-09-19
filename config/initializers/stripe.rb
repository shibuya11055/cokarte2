# frozen_string_literal: true

Stripe.api_key = ENV["STRIPE_SECRET_KEY"]

# 価格IDをENVから取得するヘルパ
module StripePrice
  def self.plan_to_price_id(plan)
    case plan.to_s
    when 'basic' then ENV['STRIPE_PRICE_BASIC']
    when 'pro'   then ENV['STRIPE_PRICE_PRO']
    else nil
    end
  end
end

