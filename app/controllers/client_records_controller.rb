class ClientRecordsController < ApplicationController
  def index
    @client_records = client_records.includes(:client)
    if params[:q].present?
      q = params[:q].strip
      @client_records = @client_records.joins(:client).where("CONCAT(clients.last_name, clients.first_name) LIKE ?", "%#{q}%")
    end
    case params[:sort]
    when "visited_at_asc"
      @client_records = @client_records.order(visited_at: :asc)
    when "visited_at_desc"
      @client_records = @client_records.order(visited_at: :desc)
    when "amount_asc"
      @client_records = @client_records.order(amount: :asc)
    when "amount_desc"
      @client_records = @client_records.order(amount: :desc)
    else
      @client_records = @client_records.order(visited_at: :desc)
    end
    @client_records = @client_records.page(params[:page]).per(20)
  end

  def show
    @client_record = client_records.find(params[:id])
  end

  def new
    @client_record = ClientRecord.new
  end

  def edit
    @client_record = client_records.find(params[:id])
  end

  def create
    @client_record = ClientRecord.new(client_record_params)
    if @client_record.save
      redirect_to client_records_path, notice: "\u30AB\u30EB\u30C6\u3092\u767B\u9332\u3057\u307E\u3057\u305F"
    else
      render :new, status: :unprocessable_entity
    end
  end

  def update
    @client_record = client_records.find(params[:id])
    if @client_record.update(client_record_params)
      redirect_to client_record_path(@client_record), notice: "\u30AB\u30EB\u30C6\u60C5\u5831\u3092\u66F4\u65B0\u3057\u307E\u3057\u305F"
    else
      render :edit, status: :unprocessable_entity
    end
  end

  private

  def client_record_params
    params.require(:client_record).permit(:client_id, :visited_at, :note, :amount)
  end

  def client_records
    @client_records ||= ClientRecord.joins(:client).where(clients: { user_id: current_user.id })
  end
end
