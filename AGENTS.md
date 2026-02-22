# LiveLog AGENTS.md

このファイルは、Codex を含むコーディング AI エージェント向けの最小ガイドです。  
詳細は `docs/project-map.md` と `docs/infrastructure-inventory.md` を参照してください。

## 目的

- このリポジトリで安全かつ一貫した変更を行う。
- 変更前に対象範囲と依存を把握し、不要な副作用を避ける。
- 本番環境や外部サービスの変更は、必ず人手承認を得る。

## 最初の 10 分

1. ミドルウェア起動: `docker compose up -d postgres elasticsearch`
2. セットアップ: `bin/setup --skip-server`
3. 開発サーバー起動: `bin/dev`
4. Ruby テスト: `bin/rails spec`
5. Ruby Lint: `bin/rubocop`
6. JavaScript/TypeScript Lint: `yarn run lint`

## AI エージェント向け検証コマンド

1. ミドルウェア起動: `docker compose up -d postgres elasticsearch selenium`
2. セットアップ: `bin/setup --skip-server`
3. テスト: `bin/rails spec`

## 必須チェック（変更内容に応じて実行）

- Ruby コードを変更したら: `bin/rails spec` と `bin/rubocop`
- JavaScript/TypeScript を変更したら: `yarn run lint`
- DB スキーマ（`db/schemas/*.rb`）を変更したら:
  - `bin/rails ridgepole:dry-run`
  - `bin/rails ridgepole:apply`
  - その後にテストを再実行

## ガードレール

- 本番環境や外部サービスの変更操作は、提案までに留める。実行前に必ず人手承認を得る。
- 外部副作用のあるタスク（例: `tweet:*`, `mail:*`）は明示的な指示がある場合のみ実行する。
- 既存の設計や運用前提を崩す変更をする場合は、変更理由と影響範囲を記録する。

## 詳細資料

- プロジェクト構造と変更影響: `docs/project-map.md`
- インフラ依存の棚卸し: `docs/infrastructure-inventory.md`
