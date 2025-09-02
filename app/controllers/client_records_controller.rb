class ClientRecordsController < ApplicationController
  def index
    @client_records = ClientRecord.includes(:client).order(visited_at: :desc).page(params[:page]).per(20)
  end

  def show
    @client_record = ClientRecord.find(params[:id])
  end

  def new
    @client_record = ClientRecord.new
  end

  def edit
    @client_record = ClientRecord.find(params[:id])
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
    @client_record = ClientRecord.find(params[:id])
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
end
