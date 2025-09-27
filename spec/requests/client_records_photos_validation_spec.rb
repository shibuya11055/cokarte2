require 'rails_helper'

RSpec.describe 'カルテ画像のバリデーション', type: :request do
  def create_user(email)
    User.create!(first_name: 'U', last_name: 'A', email: email, password: 'Password1!', confirmed_at: Time.current, tos_accepted_at: Time.current)
  end

  def upload_io(content, filename:, content_type:)
    io = StringIO.new(content)
    Rack::Test::UploadedFile.new(io, content_type, original_filename: filename)
  end

  it '非画像MIMEは422' do
    user = create_user('mime@example.com')
    login_as user, scope: :user
    client = Client.create!(user_id: user.id, first_name: '太郎', last_name: '山田', birthday: '1990-01-01')
    record = ClientRecord.create!(client: client, visited_at: Time.current)

    txt = 'hello world'
    file = upload_io(txt, filename: 'note.txt', content_type: 'text/plain')
    patch client_record_path(record), params: { client_record: { note: 'n', photos: [file] } }
    expect(response.status).to eq 422
    expect(response.body).to include('画像ファイルを選択してください')
  end

  it 'サイズ上限超過は422' do
    user = create_user('size@example.com')
    login_as user, scope: :user
    client = Client.create!(user_id: user.id, first_name: '太郎', last_name: '山田', birthday: '1990-01-01')
    record = ClientRecord.create!(client: client, visited_at: Time.current)

    # 6MBのダミー
    big = 'a' * (6 * 1024 * 1024)
    file = upload_io(big, filename: 'big.jpg', content_type: 'image/jpeg')
    patch client_record_path(record), params: { client_record: { note: 'n', photos: [file] } }
    expect(response.status).to eq 422
    expect(response.body).to include('画像は1枚5MB以下にしてください')
  end
end

