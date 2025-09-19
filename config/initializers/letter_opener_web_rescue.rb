# frozen_string_literal: true

# letter_opener_web が壊れたメール（plain.html/rich.html が欠損）を一覧で描画しようとすると
# Errno::ENOENT で 500 になることがある。その場合に空文字を返すようにして一覧の描画を継続し、
# 画面の X ボタンで当該メールを削除できるようにするパッチ。
# オートロード順に左右されないように to_prepare でパッチを適用
Rails.application.config.to_prepare do
  begin
    require 'letter_opener_web/letter'
  rescue LoadError
  end

  if defined?(LetterOpenerWeb::Letter)
    LetterOpenerWeb::Letter.class_eval do
      # 欠損ファイルがあっても落ちないように空文字を返す
      def read_file(style)
        path = "#{base_dir}/#{style}.html"
        return '' unless ::File.file?(path)
        ::File.read(path)
      rescue Errno::ENOENT
        ''
      end
    end
  end
end
