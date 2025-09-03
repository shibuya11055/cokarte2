class ClientsController < ApplicationController
  def index
    @clients = Client.all
    if params[:q].present?
      q = params[:q].strip
      @clients = @clients.where("CONCAT(last_name, first_name) LIKE ?", "%#{q}%")
    end
    @clients = @clients.order(:id).page(params[:page]).per(20)
    # 各顧客の最新カルテを事前取得
    @latest_records = ClientRecord.where(id: ClientRecord.select("MAX(id)").where(client_id: @clients.pluck(:id)).group(:client_id)).index_by(&:client_id)
  end

  def show
    @client = Client.find(params[:id])
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
      render :new, status: :unprocessable_entity
    end
  end

  def edit
    @client = Client.find(params[:id])
  end

  def update
    @client = Client.find(params[:id])
    if @client.update(client_params)
      redirect_to client_path(@client), notice: "\u9867\u5BA2\u60C5\u5831\u3092\u66F4\u65B0\u3057\u307E\u3057\u305F"
    else
      render :edit, status: :unprocessable_entity
    end
  end

  def destroy
    @client = Client.find(params[:id])
    @client.destroy
    redirect_to clients_path, notice: "\u524A\u9664\u3057\u307E\u3057\u305F"
  end

  private

  def client_params
    params.require(:client).permit(:first_name, :last_name, :birthday, :postal_code, :address, :phone_number, :memo, :email)
  end
end
