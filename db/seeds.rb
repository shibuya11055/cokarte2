# This file should ensure the existence of records required to run the application in every environment (production,
# development, test). The code here should be idempotent so that it can be executed at any point in every environment.
# The data can then be loaded with the bin/rails db:seed command (or created alongside the database with db:setup).
#
# Example:
#
#   ["Action", "Comedy", "Drama", "Horror"].each do |genre_name|
#     MovieGenre.find_or_create_by!(name: genre_name)
#   end

# clientsテーブルのサンプルデータを30件作成
user = User.first || User.create!(email: 'sample@example.com', password: 'password', first_name: 'サンプル', last_name: 'ユーザー', confirmed_at: Time.now)

last_names = %w[佐藤 鈴木 高橋 田中 渡辺 伊藤 山本 中村 小林 加藤 吉田 山田 佐々木 山口 松本 井上 木村 林 斎藤 清水]
first_names = %w[太郎 次郎 花子 美咲 大輔 直樹 さくら 拓海 結衣 陽菜 悠斗 葵 大地 愛 菜々子 海斗 陸斗 玲奈 翼 颯太]

30.times do |i|
  Client.create!(
    user_id: user.id,
    birthday: Date.new(1990, 1, 1) + i.years,
    first_name: first_names[i % first_names.length],
    last_name: last_names[i % last_names.length],
    address: "東京都サンプル区#{i+1}-1-1",
    phone_number: "090-1234-#{sprintf('%04d', i+1)}",
    memo: "メモ#{i+1}",
    email: "client#{i+1}@example.com",
    postal_code: "100-#{sprintf('%04d', i+1)}"
  )
end

# 各clientに3件のClientRecordを作成
Client.find_each do |client|
  3.times do |j|
    ClientRecord.create!(
      client: client,
      visited_at: Time.current - rand(1..365).days - rand(0..23).hours,
      note: "来店メモ#{j+1} (#{client.last_name}#{client.first_name})",
      amount: rand(1000..10000)
    )
  end
end
