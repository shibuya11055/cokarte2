FactoryBot.define do
  factory :client do
    association :user
    first_name { '太郎' }
    last_name  { '山田' }
    birthday   { Date.new(1990,1,1) }
    first_name_kana { nil }
    last_name_kana { nil }
    email { nil }
  end
end

