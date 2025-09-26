# cokarte LP および 特定商取引法ページ 対応設計

## 目的
- Stripe本番要件を満たす公開ウェブサイトを用意する。
  - ロック（会員限定アクセス）のない公開ページ。
  - 商品・サービスの詳細と価格の明示。
  - 「特定商取引法に基づく表記」ページの設置と、容易に到達できる導線（フッター/ナビ）。
- 既存アプリのUXを損なわず、未ログインユーザーはLPを起点に、ログイン/新規登録へ誘導する。

## スコープ
- LP（ランディングページ）を `/` に設定（未ログインはLPを表示）。
- LPはログイン不要（公開）。
- LPに「サービス概要」「主な機能」「料金プラン概要」「CTA（ログイン/新規登録）」を掲載。
- 「特定商取引法に基づく表記」ページを新設し、LP/フッター/ナビから到達可能にする。
- 既存の規約系ページ（料金/利用規約/プライバシー/法的情報）への導線をLP/フッターに配置。

（スコープ外：SEO最適化の細部、デザイン作り込み、画像制作、多言語対応）

## ルーティング/認可方針
- ルート設定
  - `root to: 'pages#home'`（LP）。現在 `/` が顧客一覧のため、LPに変更する。
  - 顧客一覧は `/clients` を正とする（ログイン後の主動線）。
  - ログイン済みユーザーの優先遷移（任意・将来対応）：`authenticated :user do; root to: 'clients#index', as: :authenticated_root ; end`
- 公開アクション
  - `PagesController`: `home`, `pricing`, `terms`, `privacy`, `legal`, `guide`, `commerce_disclosure`（特商法）
  - `skip_before_action :authenticate_user!` を上記アクションに付与。
  - 既存で `ApplicationController` に `before_action :authenticate_user!` があるため、公開ページ側でのスキップが必須。

## LP（pages#home）要件
- 目的：サービス内容と価格の明示、登録/ログインへの誘導。
- セクション構成（最小）
  - ヒーロー：サービスの一文コピー、主要価値、CTA（`ログイン`・`無料で始める`）。
  - サービス概要：顧客管理/カルテ作成/写真/二要素認証/サブスク課金対応 など。
  - 料金プラン概要：Free/Basic/Pro の価格・主な上限（既存 `PlanQuota` を反映）。詳細は `/pricing` へリンク。
  - セキュリティ/信頼：2FA対応、Stripe決済、データ保護への簡単な言及。
  - フッター：リンク集（`/pricing`, `/terms`, `/privacy`, `/legal`, `/commerce_disclosure`, `/guide`, `ログイン`, `新規登録`）。
- ナビ/導線
  - ヘッダー（未ログイン時）：`料金`, `使い方`, `ログイン`, `無料で始める`（新規登録）。
  - ログイン/新規登録リンクは `new_user_session_path`, `new_user_registration_path` を使用。
- 公開要件（Stripe）
  - 価格の明示：金額/課金周期/税込税別の表記（内部運用に合わせる）。
  - サービスの詳細：機能概要、提供形態（SaaS/デジタル役務）を簡潔に記載。

## 特定商取引法に基づく表記（pages#commerce_disclosure）要件
- ページタイトル：`特定商取引法に基づく表記`（推奨。代替：`通信販売に関する表示事項`）
- 必須項目（例：SaaS/デジタル役務向け）
  - 販売事業者（社名/屋号）
  - 代表者/運営責任者
  - 所在地（住所）
  - 連絡先（電話番号・メールアドレス）
  - ホームページURL
  - 販売価格（役務の対価）・付帯費用（消費税/通信料/振込手数料 等）
  - 代金の支払時期・方法（Stripe/クレジットカード、引落タイミング）
  - サービス提供時期（決済後すぐ/アカウント有効化後 等）
  - 返品・キャンセル（役務の特性上の可否、日割/中途解約、返金ポリシー）
  - 動作環境（対応ブラウザ 等）
  - 表現・商品に関する注意書き（結果を保証しない旨 等）
  - 特別な販売条件（最低利用期間/制限事項 があれば）
- 導線：LPヘッダー/フッター、`/pricing`、決済直前画面（将来追加）からリンク。

## 既存ページとの関係
- 既存ルート：`/pricing`, `/terms`, `/privacy`, `/legal`, `/guide` は維持。
- サイドメニュー（ログイン後）には追加不要だが、フッター/LPのナビに外部公開リンクを配置。

## レイアウト/UI方針
- 未ログイン時はサイドメニューを表示せず、LP用の軽量セクションを表示。
- 既存 `application.html.erb` にフッターを追加し、公開リンクを集約（もしくはLP専用簡易レイアウトを導入）。
- 画像アセットはPropshaftで配信（`app/assets/images` + manifest済）。

## ナビゲーション構成（ヘッダー/フッター）
- ヘッダー（未ログイン時：LP/公開ページ）
  - 左：ロゴ（`root_path`）。
  - 右：
    - `料金` → `pricing_path`
    - `使い方` → `guide_path`
    - `特定商取引法に基づく表記` → `commerce_disclosure_path`
    - 仕切り
    - `ログイン` → `new_user_session_path`
    - `無料で始める`（強調CTA） → `new_user_registration_path`
- ヘッダー（ログイン時：アプリ内）
  - 既存のトップバー＋ハンバーガー（サイドメニュー）を継続。
  - サイドメニューに主導線：`ダッシュボード`（任意）、`顧客一覧`（`clients_path`）、`カルテ一覧`、`カルテ作成`、`ユーザー情報`、`料金プラン`、`使い方`、`二要素認証`、`ログアウト`。
  - `root_path` はLPのため、アプリ内ホーム導線は `clients_path`（または`dashboard_path`）を利用。
- フッター（全ページ共通推奨。少なくとも公開ページには必須）
  - `ホーム` → `root_path`
  - `料金` → `pricing_path`
  - `特定商取引法に基づく表記` → `commerce_disclosure_path`
  - `利用規約` → `terms_path`
  - `プライバシー` → `privacy_path`
  - `法的情報` → `legal_path`
  - `使い方` → `guide_path`
  - （右端）`ログイン` → `new_user_session_path` / `新規登録` → `new_user_registration_path`（未ログイン時のみ表示。ログイン時は省略可）

### ルート・ヘルパ整理
- 追加ルート：`get 'commerce_disclosure', to: 'pages#commerce_disclosure', as: :commerce_disclosure`
- 既存：`pricing_path`, `terms_path`, `privacy_path`, `legal_path`, `guide_path`
- 認証系：`new_user_session_path`, `new_user_registration_path`
- アプリ内：`clients_path`, `dashboard_path`（導入時）

## 受け入れ条件（AC）
1. 未ログインで `/` にアクセスするとLPが表示される（200）。
2. LP内にサービス概要と価格が明示され、`ログイン`・`新規登録` のCTAがある。
3. `特定商取引法に基づく表記` ページが存在し、フッターまたはナビから1クリックで到達可能。
4. `/pricing`, `/terms`, `/privacy`, `/legal`, `/guide` へLPから遷移できる。
5. ログイン後は業務画面（例：顧客一覧 or ダッシュボード）へ導線がある。
6. 公開ページは `authenticate_user!` によってブロックされない。
7. ヘッダー/フッターから「特定商取引法に基づく表記」へ1クリックで遷移できる（LPおよび決済導線上のページ）。

## 実装タスク（工程）
1) ルート/コントローラ
   - `PagesController#home, #commerce_disclosure` を追加。
   - `skip_before_action :authenticate_user!, only: %i[home pricing terms privacy legal guide commerce_disclosure]` を設定。
   - `root to: 'pages#home'` に変更（従来の `root to: 'clients#index'` を差し替え）。
   - 顧客一覧は `/clients` でアクセス（`resources :clients` を維持）。
   - （任意）`authenticated :user do; root to: 'clients#index', as: :authenticated_root; end` を設定。

2) ビュー
   - `app/views/pages/home.html.erb`：ヒーロー/概要/料金ダイジェスト/CTA/フッターリンク。
   - `app/views/pages/commerce_disclosure.html.erb`：特商法の必須項目をセクションで列挙。
   - 既存 `pricing/terms/privacy/legal/guide` へのリンクを設置。

3) レイアウト
   - フッターに公開リンク集を配置（全ページ共通 or LP限定）。
   - メタ情報：タイトル/説明（最低限）。

4) 文面/表示内容（プレースホルダ可）
   - 価格：税込/税別の明記、課金周期、各プランの主な上限。
   - 特商法項目：実データ（事業者名/住所/連絡先 等）の確定が必要（後から差し替え可能な構造に）。

## リスク/留意点
- `ApplicationController` の `authenticate_user!` により公開ページが遮断されやすい点に注意。必ず `skip_before_action` を行う。
- LP公開に伴うサイドメニュー・トップバーの表示条件（未ログイン時は非表示）を維持。
- 価格/表記はStripe審査に影響するため、曖昧な表現を避ける（決済タイミング・返金可否を明記）。

## 将来拡張
- 決済直前ページやチェックアウトにも特商法/規約リンクを明示。
- LPのA/Bテストや簡易コンバージョントラッキング。
- FAQ/お問い合わせフォーム追加。
