require "rails_helper"

RSpec.describe "顧客一覧の最新カルテ表示", type: :request do
  it "IDではなく visited_at が最新のカルテを表示する" do
    user = create(:user, email: "latest@example.com")
    client = create(:client, user: user)
    latest_by_visit = create(:client_record, client: client, visited_at: Time.zone.parse("2025-03-01 10:00:00"))
    older_inserted_later = create(:client_record, client: client, visited_at: Time.zone.parse("2025-01-01 10:00:00"))

    login_as user, scope: :user
    get clients_path

    expect(response).to have_http_status(:ok)
    expect(response.body).to include("2025/03/01 10:00")
    expect(response.body).not_to include("2025/01/01 10:00")
    expect(response.body).to include(client_record_path(latest_by_visit))
    expect(response.body).not_to include(client_record_path(older_inserted_later))
  end
end
