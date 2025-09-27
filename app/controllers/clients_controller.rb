class ClientsController < ApplicationController
  before_action :ensure_client_quota!, only: [:create]
  def index
    @clients = clients
    if params[:q].present?
      q = params[:q].strip
      @clients = @clients.where(
        "CONCAT(last_name, first_name) LIKE :q OR CONCAT(last_name_kana, first_name_kana) LIKE :q",
        q: "%#{q}%"
      )
    end
    @clients = @clients.order(:id).page(params[:page]).per(20)
    # 各顧客の最新カルテを事前取得
    @latest_records = ClientRecord.where(id: ClientRecord.select("MAX(id)").where(client_id: @clients.pluck(:id)).group(:client_id)).index_by(&:client_id)
  end

  def show
    @client = clients.find(params[:id])
  end

  def new
    @client = Client.new
  end

  def create
    @client = Client.new(client_params)
    @client.user_id = current_user.id
    if @client.save
      redirect_to client_path(@client), notice: "\u9867\u5BA2\u3092\u767B\u9332\u3057\u307E\u3057\u305F"
    else
      if @client.errors[:email].present?
        flash.now[:alert] = 'このメールアドレスは既に登録されています。別のメールアドレスをご利用ください。'
      end
      render :new, status: :unprocessable_entity
    end
  rescue ActiveRecord::RecordNotUnique
    # DB制約違反（レース等）でも丁寧に案内
    @client.errors.add(:email, 'は既に登録されています')
    flash.now[:alert] = 'このメールアドレスは既に登録されています。別のメールアドレスをご利用ください。'
    render :new, status: :unprocessable_entity
  end

  def edit
    @client = clients.find(params[:id])
  end

  def update
    @client = clients.find(params[:id])
    if @client.update(client_params)
      redirect_to client_path(@client), notice: "\u9867\u5BA2\u60C5\u5831\u3092\u66F4\u65B0\u3057\u307E\u3057\u305F"
    else
      if @client.errors[:email].present?
        flash.now[:alert] = 'このメールアドレスは既に登録されています。別のメールアドレスをご利用ください。'
      end
      render :edit, status: :unprocessable_entity
    end
  rescue ActiveRecord::RecordNotUnique
    @client.errors.add(:email, 'は既に登録されています')
    flash.now[:alert] = 'このメールアドレスは既に登録されています。別のメールアドレスをご利用ください。'
    render :edit, status: :unprocessable_entity
  end

  def destroy
    @client = clients.find(params[:id])
    @client.destroy
    redirect_to clients_path, notice: "\u524A\u9664\u3057\u307E\u3057\u305F"
  end

  private

  def client_params
    params.require(:client).permit(
      :first_name,
      :last_name,
      :first_name_kana,
      :last_name_kana,
      :birthday,
      :postal_code,
      :address,
      :phone_number,
      :memo,
      :email
    )
  end

  def clients
    @clients ||= current_user.clients
  end

  def ensure_client_quota!
    limit = current_user.respond_to?(:client_limit) ? current_user.client_limit : nil
    return if limit.nil? # 無制限
    if current_user.clients_count.to_i >= limit
      redirect_to clients_path, alert: "プランの上限に達しました。上位プランへのアップグレードをご検討ください。" and return
    end
  end
end
