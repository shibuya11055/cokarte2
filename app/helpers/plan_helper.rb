# frozen_string_literal: true

module PlanHelper
  def client_limit_display(user)
    limit = user.client_limit
    limit.nil? ? '∞' : limit.to_s
  end

  def plan_badge(user)
    limit = user.client_limit
    count = user.clients_count.to_i
    warn = false
    if limit
      percent = (count.to_f / limit * 100).round
      warn = percent >= 80
    end

    content_tag :div, class: ["plan-badge", (warn ? 'warn' : nil)].compact.join(' ') do
      concat content_tag(:span, "プラン: #{user.plan_tier}")
      concat content_tag(:span, "顧客: #{count}/#{client_limit_display(user)}", class: 'sep')
      concat content_tag(:span, "画像/カルテ: #{user.photos_per_record}枚", class: 'sep')
      if limit && count >= limit
        concat link_to('プラン変更', pricing_path, class: 'btn-upgrade')
      elsif warn
        concat link_to('アップグレード', pricing_path, class: 'btn-upgrade subtle')
      end
    end
  end
end

