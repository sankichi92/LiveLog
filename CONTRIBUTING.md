# Contributing to LiveLog

以下はあくまでガイドラインです。気軽にこの文章へのプルリクエストを送ってください。

## How to Contribute

### Reporting Bugs

- **セキュリティに関するバグの場合は，Issue を立てないでください。** miyoshi@ku-unplugged.net までご連絡ください。
- セキュリティに関するもの以外であれば，[新しい Issue を立ててください](https://github.com/rails/rails/issues/new)。Issue には，分かりやすいタイトルと，バグに関するできる限り具体的な説明を含めてください。

### Suggesting Enhancements

- [新しい Issue を立ててください](https://github.com/rails/rails/issues/new)。Issue には，分かりやすいタイトルと，その変更が必要な理由や新しい機能の使い方を含めてください。

### Sending Pull Requests

- Pull Request には，変更内容を端的に示したタイトルをつけてください。
- Pull Request には，タイトルと無関係なコミットを含めないでください。
- コードやコミットメッセージ，参照している Issue に十分な情報があれば，Pull Request に詳細な説明は必要ありません。そうでなければ，どのような変更をなぜ行ったかわかるように具体的な説明を Pull Request に含めてください。
- Model に変更がある場合は，model spec を書いてください。また，Controller や View の変更に関しては，必要に応じて feature spec を書いてください。API の変更であれば，request spec を書いてください。
- Pull Request が完成していない場合やレビュー対応中である場合など，まだレビューできない状態であれば，タイトルの先頭に `[WIP]` をつけてください（Collaborator は `wip` ラベルで運用してください）。
- Styleguides に従ってください。

### For Collaborators

- 取り組むつもりの Issue には，Assignees を設定してください。
- Fork したリポジトリではなく [sankichi92/LiveLog](https://github.com/sankichi92/LiveLog) に Branch を追加して Pull Request を送ってください。

## Styleguides

### Git Commit Messages

- コミットメッセージは原型の動詞ではじめてください。また，文頭は大文字にしてください。
- 最初の1行は 72 文字以下にしてください。

### Ruby Styleguide

- Rubocop の指摘に従ってください。ただし，LiveLog の `.rubocop.yml` はまだ洗練されていません。気軽に Pull Request を送ってください。

### JavaScript Styleguide

- できる限り書かずに，Bootstrap の機能を活用してください🙏

### CSS Styleguide

- できる限り書かずに，Bootstrap の機能を活用してください🙏
