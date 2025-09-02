# client_records テーブル設計

| カラム名      | データ型    | 制約                | 説明           |
|:------------- |:---------- |:------------------- |:-------------- |
| id            | bigint     | primary key         | 主キー         |
| client_id     | bigint     | foreign key, null: false | 顧客ID (clients参照) |
| visited_at    | datetime   | null: false         | 来店日時       |
| note          | text       |                     | メモ           |
| amount        | integer    |                     | 金額           |
| created_at    | datetime   | null: false         | レコード作成日時|
| updated_at    | datetime   | null: false         | レコード更新日時|

- `client_id`は`clients`テーブルへの外部キー制約を持つ。
- `visited_at`は必須。
- `note`は任意のメモ。
- `amount`は金額（整数、任意）。
- `created_at`/`updated_at`はRails標準のタイムスタンプ。
