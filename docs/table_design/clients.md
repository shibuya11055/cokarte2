# clientsテーブル設計

| カラム名        | データ型         | 制約             | 説明                        |
|----------------|------------------|------------------|-----------------------------|
| idm            | BIGINT           | PRIMARY KEY      | クライアントID              |
| birthday       | DATE             | NOT NULL         | 生年月日                    |
| first_name     | VARCHAR(50)      | NOT NULL         | 名                          |
| last_name      | VARCHAR(50)      | NOT NULL         | 姓                          |
| address        | VARCHAR(255)     |                  | 住所                        |
| phone_number   | VARCHAR(20)      |                  | 電話番号                    |
| memo           | TEXT             |                  | メモ                        |
| email          | VARCHAR(100)     | UNIQUE           | メールアドレス              |
| postal_code    | VARCHAR(10)      |                  | 郵便番号                    |
| user_id        | BIGINT           | FOREIGN KEY      | ユーザーID（外部キー）      |
| created_at     | TIMESTAMP        | DEFAULT CURRENT_TIMESTAMP | 作成日時           |
| updated_at     | TIMESTAMP        | DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP | 更新日時 |
