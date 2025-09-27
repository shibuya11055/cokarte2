require 'rails_helper'

RSpec.describe 'カルテ一覧の並び替え', type: :request do
  def user(email)
    create(:user, email: email)
  end

  it 'visited_atの昇順/降順を切り替えられる' do
    u = user('sort1@example.com')
    login_as u, scope: :user
    c = create(:client, user: u)
    older = create(:client_record, client: c, visited_at: 2.days.ago, note: 'old')
    newer = create(:client_record, client: c, visited_at: 1.day.ago, note: 'new')

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
    c = create(:client, user: u, last_name: '佐藤', first_name: '花子')
    low  = create(:client_record, client: c, amount: 100)
    high = create(:client_record, client: c, amount: 200)

    get client_records_path, params: { sort: 'amount_desc' }
    body = response.body
    expect(body.index('¥200')).to be < body.index('¥100')

    get client_records_path, params: { sort: 'amount_asc' }
    body = response.body
    expect(body.index('¥100')).to be < body.index('¥200')
  end
end
