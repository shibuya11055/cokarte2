class ClientRecordsController < ApplicationController
  before_action :set_available_clients, only: [ :new, :create, :edit, :update ]

  def index
    @client_records = client_records.includes(:client)
    if params[:q].present?
      q = params[:q].strip
      @client_records = @client_records.joins(:client).where("CONCAT(clients.last_name, clients.first_name) LIKE ?", "%#{q}%")
    end
    case params[:sort]
    when "visited_at_asc"
      @client_records = @client_records.order(Arel.sql("client_records.visited_at ASC, client_records.id ASC"))
    when "visited_at_desc"
      @client_records = @client_records.order(Arel.sql("client_records.visited_at DESC, client_records.id DESC"))
    when "amount_asc"
      @client_records = @client_records.order(Arel.sql("client_records.amount ASC, client_records.id ASC"))
    when "amount_desc"
      @client_records = @client_records.order(Arel.sql("client_records.amount DESC, client_records.id DESC"))
    else
      @client_records = @client_records.order(Arel.sql("client_records.visited_at DESC, client_records.id DESC"))
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
    # Ensure the client belongs to current_user. If client_id is missing, let validation return 422.
    client_id = params.dig(:client_record, :client_id)
    @client_record = ClientRecord.new(client_record_params)
    if client_id.present?
      if Client.exists?(id: client_id)
        client = current_user.clients.find_by(id: client_id)
        return head :not_found unless client
        @client_record.client = client
      else
        # client_idが不正（存在しない）場合はバリデーションで422にする
        # （@client_recordにclient_idは渡っているため、must existのエラーが付与される）
      end
    end
    files = photo_files
    if files.present? && !validate_photo_files(files, existing_count: 0)
      render :new, status: :unprocessable_content and return
    end

    if save_with_photos(@client_record, files)
      redirect_to client_records_path, notice: "\u30AB\u30EB\u30C6\u3092\u767B\u9332\u3057\u307E\u3057\u305F"
    else
      render :new, status: :unprocessable_content
    end
  end

  def update
    @client_record = client_records.find(params[:id])
    # If client_id is provided, ensure it belongs to current_user, then reassign
    if params.dig(:client_record, :client_id).present?
      new_client = current_user.clients.find_by(id: params[:client_record][:client_id])
      return head :not_found unless new_client
      @client_record.client = new_client
    end
    files = photo_files
    to_remove = attachments_to_remove(@client_record)
    effective_existing = @client_record.photos.count - to_remove.size

    if files.present? && !validate_photo_files(files, existing_count: effective_existing)
      render :edit, status: :unprocessable_content and return
    end

    if update_with_photos(@client_record, client_record_params, files, to_remove)
      redirect_to client_record_path(@client_record), notice: "\u30AB\u30EB\u30C6\u60C5\u5831\u3092\u66F4\u65B0\u3057\u307E\u3057\u305F"
    else
      render :edit, status: :unprocessable_content
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
    # プランで定義された画像枚数上限があればそれを優先して使用する
    max_photos = if @client_record.client&.user&.respond_to?(:photos_per_record)
                   @client_record.client.user.photos_per_record
                  else
                    ClientRecord::MAX_PHOTOS
                  end
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
  def build_uploaded_blobs(record, files)
    user_id = current_user.id
    client_id = record.client_id
    blobs = []

    files.each do |file|
      optimized = ImageOptimizer.optimize(file)

      original = file.original_filename.to_s
      basename = File.basename(original, File.extname(original))
      ext = File.extname(optimized.filename).downcase.presence || ".jpg"
      safe_name = sanitize_filename(basename)
      key = [ user_id, client_id, "#{safe_name}-#{SecureRandom.hex(4)}#{ext}" ].join("/")
      blobs << ActiveStorage::Blob.create_and_upload!(
        io: optimized.io,
        filename: optimized.filename,
        content_type: optimized.content_type,
        key: key
      )
    end

    blobs
  rescue StandardError => e
    blobs.each(&:purge)
    raise e
  end

  def sanitize_filename(name)
    # allow alphanumerics, dash, underscore; replace others with _
    sanitized = name.to_s.gsub(/[^a-zA-Z0-9_\-]+/, "_").gsub(/^_+|_+$/, "")
    sanitized.present? ? sanitized : "image"
  end

  def client_records
    @client_records ||= ClientRecord.joins(:client).where(clients: { user_id: current_user.id })
  end

  def set_available_clients
    @clients = current_user.clients.order(:last_name_kana, :first_name_kana, :last_name, :first_name, :id)
  end

  def save_with_photos(record, files)
    uploaded_blobs = files.present? ? build_uploaded_blobs(record, files) : []

    ActiveRecord::Base.transaction do
      record.photos = uploaded_blobs if uploaded_blobs.present?
      record.save!
    end
    true
  rescue ActiveRecord::RecordInvalid
    uploaded_blobs&.each(&:purge)
    false
  rescue StandardError => e
    uploaded_blobs&.each(&:purge)
    Rails.logger.error("[ClientRecord] create with photos failed: #{e.class}: #{e.message}")
    record.errors.add(:base, "画像のアップロードに失敗しました。時間をおいて再度お試しください")
    false
  end

  def update_with_photos(record, attrs, files, to_remove)
    uploaded_blobs = files.present? ? build_uploaded_blobs(record, files) : []
    kept_blobs = record.photos.attachments.reject { |attachment| to_remove.include?(attachment) }.map(&:blob)

    ActiveRecord::Base.transaction do
      record.assign_attributes(attrs)
      record.photos = kept_blobs + uploaded_blobs
      record.save!
    end

    purge_removed_blobs_safely(to_remove)
    true
  rescue ActiveRecord::RecordInvalid
    uploaded_blobs&.each(&:purge)
    false
  rescue StandardError => e
    uploaded_blobs&.each(&:purge)
    Rails.logger.error("[ClientRecord] update with photos failed: #{e.class}: #{e.message}")
    record.errors.add(:base, "画像のアップロードに失敗しました。時間をおいて再度お試しください")
    false
  end

  def purge_removed_blobs_safely(attachments)
    attachments.each do |attachment|
      blob = attachment.blob
      blob.purge if blob.attachments.reload.none?
    rescue StandardError => e
      Rails.logger.error("[ClientRecord] photo purge failed: #{e.class}: #{e.message}")
    end
  end
end
