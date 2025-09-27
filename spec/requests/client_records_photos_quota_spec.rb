require 'rails_helper'

RSpec.describe "カルテの画像枚数クォータ", type: :request do
  def create_user(plan: 'free', count: 0)
    User.create!(first_name: 'Test', last_name: 'User', email: "#{plan}-photos@example.com", password: 'Password1!', confirmed_at: Time.current, tos_accepted_at: Time.current, plan_tier: plan, clients_count: count)
  end

  def uploaded_image(name: 'test.jpg')
    # 1x1 px JPEG header (minimal) to keep test small
    io = StringIO.new("\xFF\xD8\xFF\xE0\x00\x10JFIF\x00\x01\x01\x00\x00\x01\x00\x01\x00\x00\xFF\xD9".b)
    Rack::Test::UploadedFile.new(io, 'image/jpeg', original_filename: name)
  end

  it 'Freeプランでは1カルテあたり1枚の上限が適用される' do
    user = create_user(plan: 'free')
    login_as user, scope: :user
    client = Client.create!(user_id: user.id, first_name: '太郎', last_name: '山田', birthday: '1990-01-01')
    record = ClientRecord.create!(client: client, visited_at: Time.current)

    # 1枚追加 → 成功
    patch client_record_path(record), params: { client_record: { note: 'n', photos: [uploaded_image(name: 'a.jpg')] } }
    expect(response).to redirect_to(client_record_path(record))

    # さらに1枚追加（合計2枚）→ 422で失敗
    patch client_record_path(record), params: { client_record: { note: 'n2', photos: [uploaded_image(name: 'b.jpg')] } }
    expect(response.status).to eq 422
    expect(response.body).to include('画像は最大1枚まで保存できます')
  end
end
