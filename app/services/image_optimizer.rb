# frozen_string_literal: true

# 画像のアップロード前にリサイズ/圧縮を行う軽量オプティマイザ。
# - 可能なら ImageProcessing(MiniMagick) で長辺1600px・JPEG品質80に変換
# - EXIFは基本除去、向きはauto-orient
# - 失敗した場合は元のIOをそのまま返す

class ImageOptimizer
  MAX_SIZE = 1600
  QUALITY  = 80

  Result = Struct.new(:io, :filename, :content_type)

  def self.optimize(uploaded_file)
    content_type = uploaded_file.content_type.to_s
    original_name = uploaded_file.original_filename.to_s

    # 対象は画像のみ
    return Result.new(uploaded_file, original_name, content_type) unless content_type.start_with?("image/")

    # GIF/アニメ等はそのまま
    return Result.new(uploaded_file, original_name, content_type) if content_type.include?("gif")

    begin
      require 'image_processing/mini_magick'

      processed = ImageProcessing::MiniMagick
                    .source(uploaded_file)
                    .loader(page: 0)
                    .auto_orient
                    .resize_to_limit(MAX_SIZE, MAX_SIZE)
                    .saver(quality: QUALITY, strip: true)
                    .convert('jpg')
                    .call

      # Rewind to ensure IO is ready for upload
      processed.rewind if processed.respond_to?(:rewind)

      new_name = basename_without_ext(original_name) + '.jpg'
      Result.new(processed, new_name, 'image/jpeg')
    rescue StandardError
      # 変換できない環境/失敗時はオリジナルをそのまま返す
      Result.new(uploaded_file, original_name, content_type)
    end
  end

  def self.basename_without_ext(name)
    File.basename(name.to_s, File.extname(name.to_s))
  end
end

