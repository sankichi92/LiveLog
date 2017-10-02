# Contributing to LiveLog

The followings are written only in Japanese.  
We're waiting for your translate contribution!

LiveLog の開発に興味を持っていただき，ありがとうございます！

この文章は，LiveLog の開発に関するガイドラインです。  
厳格な規則などではなく，あくまでガイドラインですので，必ずしも従う必要はありません。  
まだまだ不十分な箇所も多いので，気軽にこの文章へのプルリクエストを送ってください！

## 質問したいだけの場合は？

[Gitter のチャットルーム](https://gitter.im/ku-unplugged-livelog/Lobby) があります。
何でも気軽に相談してください！

## 必要な前提知識は？

### Git / GitHub

LiveLog のコードは [Git](https://git-scm.com/) で管理され，[GitHub](https://github.com/) にホスティングされています。LiveLog にコードの変更を加えるには，これらのツール・サービスを使う必要があります。

Git と GitHub を勉強するのには，以下のリンクがおすすめです。

- [サルでもわかるGit入門](http://www.backlog.jp/git-guide/)
- [大塚弘記『GitHub実践入門』](http://amzn.to/2gBtlRK)
- [Pro Git 2nd Edition](https://git-scm.com/book/ja/v2)

### Ruby / Ruby on Rails

LiveLog は，主に プログラミング言語 [Ruby](https://www.ruby-lang.org/ja/) で [Ruby on Rails](http://rubyonrails.org/) というフレームワークを使って書かれています。また，テストには [RSpec](http://rspec.info/) を，HTML の記述には [Haml](http://haml.info/) を，フロントエンドフレームワークには [Bootstrap](http://getbootstrap.com/) を利用しています。

Ruby on Rails を用いた Web アプリケーション開発の基礎を勉強するには，以下のリンクがおすすめです。

- [cookpad-17day-tech-internship-2017-rails](https://speakerdeck.com/moro/cookpad-17day-tech-internship-2017-rails)
- [Ruby on Rails チュートリアル](http://railstutorial.jp/)
- [Ruby on Rails ガイド](http://railsguides.jp/)

## コントリビュートするには？

### バグを報告する

- **セキュリティに関するバグの場合は，GitHub に Issue を立てないでください。** miyoshi@ku-unplugged.net までご連絡ください。
- セキュリティに関するもの以外であれば，[新しい Issue を立ててください](https://github.com/rails/rails/issues/new)。Issue には，分かりやすいタイトルと，バグに関するできる限り具体的な説明を含めてください。

### 機能改善や新機能を提案する

- [新しい Issue を立ててください](https://github.com/rails/rails/issues/new)。Issue には，分かりやすいタイトルと，その変更が必要な理由や新しい機能の使い方を含めてください。

### Pull Request を送る

- Pull Request には，変更内容を端的に示したタイトルをつけてください。
- Pull Request には，タイトルと無関係なコミットを含めないでください。
- コードやコミットメッセージ，参照している Issue に十分な情報があれば，Pull Request に詳細な説明は必要ありません。そうでなければ，どのような変更をなぜ行ったかわかるように具体的な説明を Pull Request に含めてください。
- テストを書いてください。テストは，加えたコードがないと失敗し，あることで成功するようにしてください。
- Pull Request が完成していない場合やレビュー対応中である場合など，まだレビューできない状態であれば，タイトルの先頭に `[WIP]` をつけてください。
- 以下のスタイルガイドに従ってください。

## スタイルガイド

### Git コミットメッセージ

- コミットメッセージは原型の動詞ではじめてください。また，文頭は大文字にしてください。
- 最初の1行は 72 文字以下にしてください。

### Ruby

- 基本的には，Rubocop の指摘に従ってください。ただし，LiveLog の `.rubocop.yml` はまだ洗練されていません。気軽に Pull Request を送ってください。

### JavaScript

- まだありません。できるだけ書かずに，Bootstrap の機能を活用してください🙏

### CSS

- まだありません。できるだけ書かずに，Bootstrap の機能を活用してください🙏

## Collaborator の方へ

- 取り組むつもりの Issue には，Assignees を設定してください。
