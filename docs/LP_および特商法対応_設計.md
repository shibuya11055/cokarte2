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
  - `PagesController`: `home`のみ。特商法ページなどは存在するためそのリンクを設置する。
  - `skip_before_action :authenticate_user!` を上記アクションに付与。
  - 既存で `ApplicationController` に `before_action :authenticate_user!` があるため、公開ページ側でのスキップが必須。

## LP（pages#home）要件
- 目的：サービス内容と価格の明示、登録/ログインへの誘導。
- セクション構成（最小）
  - ヒーロー：サービスの一文コピー、主要価値、CTA（`ログイン`・`無料で始める`）。
  - サービス概要：顧客管理/カルテ作成/写真/二要素認証/サブスク課金対応 など。
    - シンプルな機能に絞っている・複雑な機能はない・その分安いことをアピール
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
app/views/pages/legal.html.erb にある。

## 既存ページとの関係
既存ページへ遷移する動線はない

## レイアウト/UI方針
- 未ログイン時はサイドメニューを表示せず、LP用の軽量セクションを表示。
- 画像アセットはPropshaftで配信（`app/assets/images` + manifest済）。

### ルート・ヘルパ整理
- 既存：`pricing_path`, `terms_path`, `privacy_path`, `legal_path`, `guide_path`
- 認証系：`new_user_session_path`, `new_user_registration_path`

## 受け入れ条件（AC）
1. 未ログインで `/` にアクセスするとLPが表示される（200）。
2. LP内にサービス概要と価格が明示され、`ログイン`・`新規登録` のCTAがある。
3. `特定商取引法に基づく表記` ページが存在し、フッターまたはナビから1クリックで到達可能。
4. `/terms`, `/privacy`, `/legal`, `/guide` へLPから遷移できる。
5. ログイン後は業務画面（例：顧客一覧 or ダッシュボード）へ導線がある。
6. LPページは `authenticate_user!` によってブロックされない。
7. フッターから「特定商取引法に基づく表記」へ1クリックで遷移できる（LPおよび決済導線上のページ）。

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

## デザイン
- アプリの色合いやデザインを踏襲しつつ、個人事業主の方がワクワクするような登録したくなるようなモダンなデザインにする
- 明るいイメージの色合いにする

## 注意
CSSの影響はLPページにとどめる。
この実装で他画面へのデザインの影響はないようにする。
