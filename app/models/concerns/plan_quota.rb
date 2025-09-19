# frozen_string_literal: true

module PlanQuota
  CLIENT_LIMIT = {
    "free"  => 50,
    "basic" => 150,
    "pro"   => nil
  }.freeze

  PHOTOS_PER_RECORD = {
    "free"  => 1,
    "basic" => 3,
    "pro"   => 3
  }.freeze

  def client_limit
    CLIENT_LIMIT.fetch(plan_tier.to_s, CLIENT_LIMIT["free"]) # allow nil for pro(unlimited)
  end

  def photos_per_record
    PHOTOS_PER_RECORD.fetch(plan_tier.to_s, PHOTOS_PER_RECORD["free"])
  end

  def remaining_clients
    limit = client_limit
    return Float::INFINITY if limit.nil?
    [limit - clients_count.to_i, 0].max
  end
end
