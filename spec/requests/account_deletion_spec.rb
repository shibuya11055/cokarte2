require "rails_helper"

RSpec.describe "アカウント削除", type: :request do
  it "関連する顧客とカルテを含めて削除できる" do
    user = create(:user, email: "withdraw@example.com")
    client = create(:client, user: user)
    create(:client_record, client: client)

    login_as user, scope: :user

    expect {
      delete user_registration_path
    }.to change(User, :count).by(-1)
      .and change(Client, :count).by(-1)
      .and change(ClientRecord, :count).by(-1)

    expect(response).to redirect_to(root_path)
  end

  it "有料プラン利用中は先に解約しないと退会できない" do
    user = create(
      :user,
      email: "withdraw-paid@example.com",
      plan_tier: "basic",
      stripe_customer_id: "cus_active",
      subscription_status: "active"
    )
    create(:client, user: user)

    login_as user, scope: :user

    expect {
      delete user_registration_path
    }.not_to change(User, :count)

    expect(response).to redirect_to(edit_user_registration_path)
    follow_redirect!
    expect(response.body).to include("先に Customer Portal で解約を完了してください")
  end

  it "解約済みなら退会できる" do
    user = create(
      :user,
      email: "withdraw-canceled@example.com",
      plan_tier: "free",
      stripe_customer_id: "cus_canceled",
      subscription_status: "canceled"
    )

    login_as user, scope: :user

    expect {
      delete user_registration_path
    }.to change(User, :count).by(-1)

    expect(response).to redirect_to(root_path)
  end
end
