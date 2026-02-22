# 保守チェックリスト

## 目的

以下のファイルを、現在のリポジトリ実態と同期させる。

- `AGENTS.md`
- `docs/project-map.md`
- `docs/infrastructure-inventory.md`
- `README.md`（AI エージェント文書へのリンク）

## 事実収集コマンド

### 構造と入口

```bash
rg --files
sed -n '1,260p' config/routes.rb
sed -n '1,260p' README.md
```

### 環境変数の棚卸し

```bash
rg -n "ENV\\[|ENV\\.fetch" app config lib db spec -g '!app/assets/builds/**'
```

### 外部サービスとインフラ結合点

```bash
rg -n "Heroku|MEMCACHIER|SENDGRID|ELASTICSEARCH_URL|AUTH0|Cloudinary|Sentry|Scout|barnes|SLACK_|TWITTER_" app config lib Gemfile Procfile* README.md docs
```

### CI と品質ゲート

```bash
sed -n '1,260p' .github/workflows/ruby.yml
sed -n '1,220p' .github/workflows/javascript.yml
cat package.json
ls -la bin
```

## 編集ルール

- `AGENTS.md` は短く保ち、詳細は別ファイルへリンクする。
- 構造と変更影響は `docs/project-map.md` に整理する。
- サービス依存と環境変数は `docs/infrastructure-inventory.md` に整理する。
- README の変更は最小限にして、導線の維持に限定する。
- 明示依頼がない限り、移行先比較は追加しない。

## 必須記載

- 本番環境・外部サービス変更には明示的な人手承認が必要であること。
- 副作用タスク（投稿、送信、外部書き込み）は opt-in であること。

## 最終チェック前コマンド

```bash
skills/livelog-agent-docs-maintainer/scripts/check_agent_docs.sh <repo-path>
```

`[ERROR]` はすべて解消してから完了する。`[WARN]` はレビュー要として扱う。
