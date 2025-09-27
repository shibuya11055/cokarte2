require 'rails_helper'

RSpec.describe 'プラン別クォータ' do
  let(:free_user)  { User.create!(first_name: 'Free',  last_name: 'User', email: 'free@example.com',  password: 'Password1!', confirmed_at: Time.current, tos_accepted_at: Time.current, plan_tier: 'free',  clients_count: 0) }
  let(:basic_user) { User.create!(first_name: 'Basic', last_name: 'User', email: 'basic@example.com', password: 'Password1!', confirmed_at: Time.current, tos_accepted_at: Time.current, plan_tier: 'basic', clients_count: 0) }
  let(:pro_user)   { User.create!(first_name: 'Pro',   last_name: 'User', email: 'pro@example.com',   password: 'Password1!', confirmed_at: Time.current, tos_accepted_at: Time.current, plan_tier: 'pro',   clients_count: 0) }

  it '各プランの顧客上限と画像上限を返す' do
    expect(free_user.client_limit).to eq 50
    expect(free_user.photos_per_record).to eq 1

    expect(basic_user.client_limit).to eq 150
    expect(basic_user.photos_per_record).to eq 3

    # ensure the attribute persisted as expected
    pro_user.update!(plan_tier: 'pro')
    expect(pro_user.client_limit).to be_nil
    expect(pro_user.photos_per_record).to eq 3
  end

  it '無制限プランを考慮して残り登録可能数を計算する' do
    free_user.update!(clients_count: 49)
    expect(free_user.remaining_clients).to eq 1

    basic_user.update!(clients_count: 100)
    expect(basic_user.remaining_clients).to eq 50

    pro_user.update!(plan_tier: 'pro', clients_count: 9999)
    expect(pro_user.remaining_clients).to eq Float::INFINITY
  end
end
