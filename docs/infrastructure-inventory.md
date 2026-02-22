# インフラ依存棚卸し（AI エージェント向け）

このドキュメントは、LiveLog の外部依存をコードベース起点で整理した棚卸しです。  
目的は「現状の把握」であり、移行先比較や移行実装は本スコープ外です。

## 1. 前提

- 現在は Heroku 時代の構成に依存する箇所がある。
- 将来的な移植・非依存化に備えて、まず依存の結合点を明確化する。
- 本番環境および外部サービスへの変更は、常に人手承認を必須とする。

## 2. 依存サービス一覧（現状）

1. PostgreSQL
- 用途: 主データストア
- 結合点: `config/database.yml`, `db/Schemafile`, `db/schemas/*.rb`
- 備考: スキーマ管理は Ridgepole

2. Elasticsearch
- 用途: 楽曲検索インデックス
- 結合点: `config/initializers/elasticsearch.rb`, `lib/tasks/elasticsearch.rake`, `app/models/concerns/song_searchable.rb`
- 関連環境変数: `ELASTICSEARCH_URL`, `ELASTICSEARCH_DEFAULT_ANALYZER_TYPE`

3. MemCachier（Memcached）
- 用途: 本番キャッシュストア
- 結合点: `config/environments/production.rb`
- 関連環境変数: `MEMCACHIER_SERVERS`, `MEMCACHIER_USERNAME`, `MEMCACHIER_PASSWORD`

4. SendGrid（SMTP）
- 用途: メール送信
- 結合点: `config/environments/production.rb`
- 関連環境変数: `SENDGRID_API_KEY`

5. AWS S3（Active Storage）
- 用途: ファイルストレージ
- 結合点: `config/storage.yml`, `config/environments/production.rb`
- 関連環境変数: `AWS_ACCESS_KEY_ID`, `AWS_SECRET_ACCESS_KEY`

6. Cloudinary
- 用途: アバター画像アップロード/配信
- 結合点: `app/models/avatar.rb`, `config/environments/production.rb`
- 関連環境変数: `CLOUDINARY_URL`

7. Auth0
- 用途: ログイン/OAuth 連携
- 結合点: `config/initializers/auth0.rb`, `config/initializers/omniauth.rb`, `app/controllers/auth_controller.rb`
- 関連環境変数: `AUTH0_CLIENT_ID`, `AUTH0_CLIENT_SECRET`, `AUTH0_DOMAIN`, `AUTH0_API_AUDIENCE`, `AUTH0_RESOURCE_SERVER_ID`

8. GitHub OAuth
- 用途: Developer 連携
- 結合点: `config/initializers/omniauth.rb`, `app/controllers/auth_controller.rb`
- 関連環境変数: `GITHUB_CLIENT_ID`, `GITHUB_CLIENT_SECRET`

9. Slack
- 用途: 通知・招待リンク
- 結合点: `config/initializers/slack.rb`, `app/jobs/*_activity_notify_job.rb`, `config/routes.rb`
- 関連環境変数: `SLACK_API_TOKEN`, `SLACK_NOTIFICATION_CHANNEL`, `SLACK_INVITATION_TOKEN`

10. Twitter(X) API
- 用途: 投稿タスク
- 結合点: `config/initializers/twitter_client.rb`, `lib/twitter_client.rb`, `lib/tasks/tweet.rake`
- 関連環境変数: `TWITTER_CONSUMER_KEY`, `TWITTER_CONSUMER_SECRET`, `TWITTER_ACCESS_TOKEN`, `TWITTER_ACCESS_TOKEN_SECRET`

11. Sentry
- 用途: エラー監視
- 結合点: `config/initializers/sentry.rb`, `app/controllers/concerns/sentry_user.rb`, `app/javascript/application.ts`, `app/javascript/admin.ts`
- 関連環境変数: DSN は運用環境側設定に依存

12. Scout APM / Barnes（Heroku 運用由来）
- 用途: APM / ランタイム計測
- 結合点: `Gemfile`, `config/puma.rb`
- 備考: 利用実態は要確認

## 3. 補助的な環境変数

- `POSTGRES_HOST`, `POSTGRES_USER`, `POSTGRES_PASSWORD`, `LIVELOG_DATABASE_PASSWORD`
- `RAILS_MAX_THREADS`, `RAILS_LOG_LEVEL`, `PORT`, `PIDFILE`
- `USE_DOCKER_SELENIUM`（system spec 実行時）

## 4. ローカル/テストでの代替挙動

- 開発:
  - `config/environments/development.rb` で `cache_store = :memory_store`
  - Active Storage は `local`
- テスト:
  - `config/environments/test.rb` で Active Storage は `test`
  - Cloudinary はテスト用固定設定
- Docker Compose:
  - PostgreSQL / Elasticsearch / Selenium を `compose.yml` で起動

## 5. 副作用タスク（実行注意）

- `bin/rails tweet:pickup_song`: 外部投稿の副作用あり
- `bin/rails mail:pickup_song`: 外部送信の副作用あり
- `bin/rails elasticsearch:import:song FORCE=y`: インデックス再構築

これらは、明示指示がある場合のみ実行する。特に本番向けは人手承認を必須とする。

## 6. 移植準備のための観点（比較はしない）

- 外部サービス依存の接続設定を「初期化子・設定ファイル」に集約維持する。
- モデル/ジョブから直接外部 API を叩く箇所は、抽象化レイヤ導入候補として識別する。
- まずは依存の可視化と変更影響の縮小を優先し、移行先の選定は別フェーズで実施する。

## 7. 関連資料

- 入口ガイド: `AGENTS.md`
- 構造マップ: `docs/project-map.md`
