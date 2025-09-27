require 'rails_helper'

RSpec.describe 'カルテ一覧の並び替え', type: :request do
  def user(email)
    User.create!(first_name: 'U', last_name: 'A', email: email, password: 'Password1!', confirmed_at: Time.current, tos_accepted_at: Time.current)
  end

  it 'visited_atの昇順/降順を切り替えられる' do
    u = user('sort1@example.com')
    login_as u, scope: :user
    c = Client.create!(user_id: u.id, last_name: '山田', first_name: '太郎', birthday: '1990-01-01')
    older = ClientRecord.create!(client: c, visited_at: 2.days.ago, note: 'old')
    newer = ClientRecord.create!(client: c, visited_at: 1.day.ago, note: 'new')

    get client_records_path, params: { sort: 'visited_at_desc' }
    body = response.body
    expect(body.index(client_record_path(newer))).to be < body.index(client_record_path(older))

    get client_records_path, params: { sort: 'visited_at_asc' }
    body = response.body
    expect(body.index(client_record_path(older))).to be < body.index(client_record_path(newer))
  end

  it 'amountの昇順/降順を切り替えられる' do
    u = user('sort2@example.com')
    login_as u, scope: :user
    c = Client.create!(user_id: u.id, last_name: '佐藤', first_name: '花子', birthday: '1990-01-01')
    low  = ClientRecord.create!(client: c, visited_at: Time.current, amount: 100)
    high = ClientRecord.create!(client: c, visited_at: Time.current, amount: 200)

    get client_records_path, params: { sort: 'amount_desc' }
    body = response.body
    expect(body.index('¥200')).to be < body.index('¥100')

    get client_records_path, params: { sort: 'amount_asc' }
    body = response.body
    expect(body.index('¥100')).to be < body.index('¥200')
  end
end
