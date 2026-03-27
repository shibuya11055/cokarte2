require "rails_helper"

RSpec.describe "カルテ画像アップロード失敗時", type: :request do
  before do
    allow(ActiveStorage::Blob).to receive(:create_and_upload!).and_raise(StandardError, "upload failed")
  end

  it "作成時はカルテを保存しない" do
    user = create(:user, email: "upload-create@example.com", plan_tier: "basic")
    client = create(:client, user: user)

    login_as user, scope: :user

    expect {
      post client_records_path, params: {
        client_record: {
          client_id: client.id,
          visited_at: Time.current,
          note: "初回",
          photos: [ tiny_jpeg ]
        }
      }
    }.not_to change(ClientRecord, :count)

    expect(response.status).to eq 422
    expect(response.body).to include("画像のアップロードに失敗しました")
  end

  it "更新時は既存画像を消さず、本文更新もロールバックする" do
    user = create(:user, email: "upload-update@example.com", plan_tier: "basic")
    client = create(:client, user: user)
    record = create(:client_record, client: client, note: "before")
    record.photos.attach(tiny_jpeg(name: "existing.jpg"))
    existing_photo_id = record.photos.attachments.first.id

    login_as user, scope: :user

    patch client_record_path(record), params: {
      client_record: {
        note: "after",
        photos: [ tiny_jpeg(name: "new.jpg") ]
      },
      remove_photo_ids: [ record.photos.attachments.first.signed_id ]
    }

    expect(response.status).to eq 422
    expect(response.body).to include("画像のアップロードに失敗しました")
    expect(record.reload.note).to eq("before")
    expect(record.photos.attachments.pluck(:id)).to include(existing_photo_id)
  end
end
