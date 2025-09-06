# == Schema Information
#
# Table name: client_records
#
#  id         :integer          not null, primary key
#  client_id  :integer          not null
#  visited_at :datetime
#  note       :text
#  amount     :integer
#  created_at :datetime         not null
#  updated_at :datetime         not null
#
# Indexes
#
#  index_client_records_on_client_id  (client_id)
#

class ClientRecord < ApplicationRecord
  belongs_to :client
  has_many_attached :photos

  MAX_PHOTOS = 3
  MAX_PHOTO_SIZE_MB = 5

  validate :validate_photos

  private

  def validate_photos
    return unless photos.attached?

    if photos.attachments.size > MAX_PHOTOS
      errors.add(:base, "画像は最大#{MAX_PHOTOS}枚まで保存できます")
    end

    photos.attachments.each do |attachment|
      blob = attachment.blob
      next unless blob

      if blob.byte_size.to_i > MAX_PHOTO_SIZE_MB.megabytes
        errors.add(:base, "画像は1枚#{MAX_PHOTO_SIZE_MB}MB以下にしてください")
      end

      content_type = blob.content_type.to_s
      unless content_type.start_with?("image/")
        errors.add(:base, "画像ファイルを選択してください")
      end
    end
  end
end
