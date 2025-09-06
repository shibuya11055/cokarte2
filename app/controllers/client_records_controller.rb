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
    files = photo_files
    if files.present? && !validate_photo_files(files, existing_count: 0)
      render :new, status: :unprocessable_entity and return
    end

    if @client_record.save
      attach_files_with_custom_key(@client_record, files) if files.present?
      redirect_to client_records_path, notice: "\u30AB\u30EB\u30C6\u3092\u767B\u9332\u3057\u307E\u3057\u305F"
    else
      render :new, status: :unprocessable_entity
    end
  end

  def update
    @client_record = client_records.find(params[:id])
    files = photo_files
    to_remove = attachments_to_remove(@client_record)
    effective_existing = @client_record.photos.count - to_remove.size

    if files.present? && !validate_photo_files(files, existing_count: effective_existing)
      render :edit, status: :unprocessable_entity and return
    end

    if @client_record.update(client_record_params)
      ActiveRecord::Base.transaction do
        to_remove.each(&:purge)
        attach_files_with_custom_key(@client_record, files) if files.present?
      end
      redirect_to client_record_path(@client_record), notice: "\u30AB\u30EB\u30C6\u60C5\u5831\u3092\u66F4\u65B0\u3057\u307E\u3057\u305F"
    else
      render :edit, status: :unprocessable_entity
    end
  end

  private

  def client_record_params
    params.require(:client_record).permit(:client_id, :visited_at, :note, :amount)
  end

  def photo_files
    Array(params.dig(:client_record, :photos)).compact_blank
  end

  def validate_photo_files(files, existing_count: 0)
    max_photos = ClientRecord::MAX_PHOTOS
    max_size = ClientRecord::MAX_PHOTO_SIZE_MB.megabytes
    if existing_count + files.size > max_photos
      @client_record.errors.add(:base, "画像は最大#{max_photos}枚まで保存できます")
      return false
    end
    files.each do |file|
      unless file.respond_to?(:content_type) && file.content_type.to_s.start_with?("image/")
        @client_record.errors.add(:base, "画像ファイルを選択してください")
        return false
      end
      if file.size.to_i > max_size
        @client_record.errors.add(:base, "画像は1枚#{ClientRecord::MAX_PHOTO_SIZE_MB}MB以下にしてください")
        return false
      end
    end
    true
  end

  def attachments_to_remove(record)
    ids = Array(params[:remove_photo_ids])
    return [] if ids.blank?
    record.photos.attachments.select { |a| ids.include?(a.signed_id) }
  end

  # Build and attach blobs with custom S3 object keys like "user_id/client_id/filename-xxxx.jpg"
  def attach_files_with_custom_key(record, files)
    user_id = current_user.id
    client_id = record.client_id
    blobs = files.map do |file|
      original = file.original_filename.to_s
      basename = File.basename(original, File.extname(original))
      ext = File.extname(original).downcase.presence || ".jpg"
      safe_name = sanitize_filename(basename)
      # add short random suffix to avoid accidental overwrite with same name
      key = [user_id, client_id, "#{safe_name}-#{SecureRandom.hex(4)}#{ext}"].join("/")
      ActiveStorage::Blob.create_and_upload!(
        io: file,
        filename: original,
        content_type: file.content_type,
        key: key
      )
    end
    record.photos.attach(blobs)
  end

  def sanitize_filename(name)
    # allow alphanumerics, dash, underscore; replace others with _
    name.to_s.gsub(/[^a-zA-Z0-9_\-]+/, "_").gsub(/^_+|_+$/, "")
  end

  def client_records
    @client_records ||= ClientRecord.joins(:client).where(clients: { user_id: current_user.id })
  end
end
