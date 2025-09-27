FactoryBot.define do
  sequence :email do |n|
    "user#{n}@example.com"
  end

  factory :user do
    first_name { 'Test' }
    last_name  { 'User' }
    email { generate(:email) }
    password { 'Password1!' }
    confirmed_at { Time.current }
    tos_accepted_at { Time.current }
    plan_tier { 'free' }
    clients_count { 0 }

    trait :basic do
      plan_tier { 'basic' }
    end

    trait :pro do
      plan_tier { 'pro' }
    end

    trait :with_2fa do
      otp_required_for_login { true }
    end
  end
end

