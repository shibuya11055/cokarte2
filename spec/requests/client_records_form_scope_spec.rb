require "rails_helper"

RSpec.describe "カルテフォームの顧客選択肢", type: :request do
  it "新規作成画面には自分の顧客だけが表示される" do
    user = create(:user, email: "scope-new@example.com")
    own_client = create(:client, user: user, first_name: "自分", last_name: "顧客")
    other_client = create(:client, first_name: "他人", last_name: "顧客")

    login_as user, scope: :user
    get new_client_record_path

    expect(response).to have_http_status(:ok)
    expect(response.body).to include("#{own_client.last_name}#{own_client.first_name}")
    expect(response.body).not_to include("#{other_client.last_name}#{other_client.first_name}")
  end

  it "編集画面にも自分の顧客だけが表示される" do
    user = create(:user, email: "scope-edit@example.com")
    own_client = create(:client, user: user, first_name: "自分", last_name: "顧客")
    other_client = create(:client, first_name: "他人", last_name: "顧客")
    record = create(:client_record, client: own_client)

    login_as user, scope: :user
    get edit_client_record_path(record)

    expect(response).to have_http_status(:ok)
    expect(response.body).to include("#{own_client.last_name}#{own_client.first_name}")
    expect(response.body).not_to include("#{other_client.last_name}#{other_client.first_name}")
  end
end
