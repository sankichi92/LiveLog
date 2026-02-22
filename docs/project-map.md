# プロジェクトマップ（AI エージェント向け）

このドキュメントは、LiveLog のコード構造・主要ドメイン・変更影響の見方をまとめたものです。  
実装方針の細部に入る前に、まずここを読んで変更範囲を特定してください。

## 1. アプリ概要

- 種別: Ruby on Rails アプリケーション（Rails 8.1 / Ruby 4.0）
- 主要機能: 軽音サークルのセットリスト管理
- インターフェース:
  - Web（公開画面）
  - Web（管理画面 `/admin`）
  - GraphQL API（`/api/graphql`）

## 2. ディレクトリの見取り図

- `app/`
  - `models/`: ドメインロジック
  - `controllers/`: Web/API エンドポイント
  - `graphql/`: GraphQL スキーマ・型・クエリ
  - `views/`: Haml テンプレート
  - `javascript/`: フロントエンド（esbuild + TypeScript + Stimulus）
  - `jobs/`: 通知や外部連携のジョブ
- `config/`
  - `routes.rb`: ルーティング全体
  - `environments/*.rb`: 環境ごとの挙動
  - `initializers/*.rb`: 外部サービス接続設定
- `db/`
  - `Schemafile`: Ridgepole の入口
  - `schemas/*.rb`: 実スキーマ定義
- `spec/`: RSpec（request/model/system/graphql/mailer）
- `.devcontainer/`: 開発コンテナ設定（PostgreSQL/Elasticsearch/Selenium を含む）

## 3. 主要ドメイン

- `Live`: 開催ライブ
- `Song`: ライブ内の楽曲
- `Member`: メンバー
- `Play`: メンバーと楽曲の演奏関係
- `Entry` / `PlayableTime`: 出演エントリーと希望時間帯
- `EntryGuideline`: 各ライブの募集要項
- `User` / `Administrator` / `Developer`: 権限・ログイン関連
- `Client`: OAuth クライアント情報

## 4. ルーティング境界

- 公開画面:
  - `songs`, `lives`, `members`, `entries`, `summaries` など
- 管理画面:
  - `admin/lives`, `admin/members`, `admin/entries` など
- API:
  - `POST /api/graphql`
  - `GET /api/scopes`

詳細は `config/routes.rb` を一次情報として確認してください。

## 5. 変更影響の見方

- モデル変更: バリデーション/関連/スコープに合わせて model・request・system spec を確認
- コントローラ変更: 対応する request spec を確認
- GraphQL 変更: `app/graphql` と `spec/graphql/queries/*` を確認
- JavaScript 変更: `app/javascript` と画面テンプレートの連携を確認
- DB 変更: `db/schemas/*.rb` と関連 model/spec を確認

## 6. 推奨検証フロー

1. 依存セットアップ: `bin/setup --skip-server`
2. Ruby Lint: `bin/rubocop`
3. JavaScript/TypeScript Lint: `yarn run lint`
4. テスト: `bin/rails spec`
5. DB スキーマ変更時:
   - `bin/rails ridgepole:dry-run`
   - `bin/rails ridgepole:apply`
   - `bin/rails spec` を再実行

## 7. 作業時の運用ルール

- 本番環境・外部サービスへの変更は、必ず人手承認を得る。
- 外部副作用のあるタスク（通知・投稿・送信系）は、明示指示なしに実行しない。
- 大きな変更では、影響範囲とロールバック可能性を先に整理する。

## 8. 関連資料

- 入口ガイド: `AGENTS.md`
- インフラ依存の棚卸し: `docs/infrastructure-inventory.md`
