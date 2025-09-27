require 'rails_helper'

RSpec.describe 'カルテ画像の上限（Basic/Pro）', type: :request do
  it 'Basic: 3枚まで許容、4枚は422' do
    user = create(:user, :basic)
    login_as user, scope: :user
    client = create(:client, user: user)
    record = create(:client_record, client: client)

    # 3枚はOK
    patch client_record_path(record), params: { client_record: { note: 'n', photos: [tiny_jpeg(name: 'a.jpg'), tiny_jpeg(name: 'b.jpg'), tiny_jpeg(name: 'c.jpg')] } }
    expect(response).to redirect_to(client_record_path(record))

    # さらに1枚追加（合計4）→ 422
    patch client_record_path(record), params: { client_record: { note: 'n2', photos: [tiny_jpeg(name: 'd.jpg')] } }
    expect(response.status).to eq 422
    expect(response.body).to include('画像は最大3枚まで保存できます')
  end

  it 'Pro: 3枚まで許容、4枚は422' do
    user = create(:user, :pro)
    login_as user, scope: :user
    client = create(:client, user: user)
    record = create(:client_record, client: client)

    patch client_record_path(record), params: { client_record: { note: 'n', photos: [tiny_jpeg(name: 'a.jpg'), tiny_jpeg(name: 'b.jpg'), tiny_jpeg(name: 'c.jpg')] } }
    expect(response).to redirect_to(client_record_path(record))

    patch client_record_path(record), params: { client_record: { note: 'n2', photos: [tiny_jpeg(name: 'd.jpg')] } }
    expect(response.status).to eq 422
    expect(response.body).to include('画像は最大3枚まで保存できます')
  end

  it '削除指定後の追加は上限内なら通る' do
    user = create(:user, :basic)
    login_as user, scope: :user
    client = create(:client, user: user)
    record = create(:client_record, client: client)

    # 2枚添付（OK）
    patch client_record_path(record), params: { client_record: { note: 'n', photos: [tiny_jpeg(name: 'a.jpg'), tiny_jpeg(name: 'b.jpg')] } }
    expect(response).to redirect_to(client_record_path(record))
    record.reload
    expect(record.photos.count).to eq 2

    # 1枚削除 + 2枚追加 → 合計3でOK
    to_remove = [record.photos.first.signed_id]
    patch client_record_path(record), params: { client_record: { note: 'n2', photos: [tiny_jpeg(name: 'c.jpg'), tiny_jpeg(name: 'd.jpg')] }, remove_photo_ids: to_remove }
    expect(response).to redirect_to(client_record_path(record))
    expect(record.reload.photos.count).to eq 3
  end
end

