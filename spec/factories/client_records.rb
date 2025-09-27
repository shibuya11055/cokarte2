FactoryBot.define do
  factory :client_record do
    association :client
    visited_at { Time.current }
    note { 'n' }
    amount { nil }
  end
end

