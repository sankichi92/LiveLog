---
name: livelog-agent-docs-maintainer
description: LiveLog の AI エージェント向け文書（`AGENTS.md`, `docs/project-map.md`, `docs/infrastructure-inventory.md`, README の導線）を継続保守する。routes、依存ライブラリ、環境変数、CI、開発コマンド、外部サービス連携の変更で文書更新が必要なときに使う。
---

# LiveLog Agent Docs Maintainer

## 概要

LiveLog の AI エージェント向けドキュメントを、実際のコードと運用実態に同期させ続ける。

## 実行ワークフロー

1. 対象ファイルを確認する。
- `AGENTS.md`
- `docs/project-map.md`
- `docs/infrastructure-inventory.md`
- `README.md`

2. 文書編集前にコードから事実を再収集する。
- routes、環境設定、initializers、rake tasks を再確認する。
- CI ワークフローとローカル開発コマンドを再確認する。
- 環境変数と外部サービス結合点を再確認する。

3. スコープを守って文書更新する。
- `AGENTS.md` は短く、実行指向を維持する。
- 詳細は `docs/project-map.md` と `docs/infrastructure-inventory.md` に置く。
- README の変更は最小限にして導線維持に限定する。
- 明示依頼がない限り、移行先比較は追加しない。

4. 必須ポリシーを反映する。
- 本番環境・外部サービス変更は、明示的な人手承認必須とする。
- 副作用タスクは明示指示がある場合のみ実行可能と記載する。

5. 整合性チェックを実行して修正する。
- `scripts/check_agent_docs.sh <repo-path>`

6. 変更結果を明確に報告する。
- 変更ファイルと変更理由を列挙する。
- 未確定事項とフォローアップを列挙する。

## リソース

- 詳細チェックリスト: `references/maintenance-checklist.md`
- 高速整合チェック: `scripts/check_agent_docs.sh`
