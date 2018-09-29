# LiveLog

[![Build Status](https://travis-ci.org/sankichi92/LiveLog.svg?branch=master)](https://travis-ci.org/sankichi92/LiveLog)
[![Gitter chat](https://badges.gitter.im/sankichi92/LiveLog.svg)](https://gitter.im/ku-unplugged-livelog/Lobby)

<img src="app/assets/images/logo.png" alt="Logo" width="200px">

This is the Ruby on Rails application to manage set lists of the acoustic light music club "[京大アンプラグド](http://ku-unplugged.net/)."

## Requirements

- Ruby 2.5.1
- PostgreSQL 9.2 or later
- [Elasticsearch](https://www.elastic.co/guide/en/elasticsearch/reference/current/install-elasticsearch.html) 5.x
  - with [Japanese (kuromoji) Analysis Plugin](https://www.elastic.co/guide/en/elasticsearch/plugins/current/analysis-kuromoji.html)

## Getting started

To get started with the app, clone the repo and then execute:

    $ bin/setup

Next, run the test suite to verify that everything is working correctly:

    $ bin/rails spec

If the test suite passes, you'll be ready to run the app in a local server:

    $ bin/rails server

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/sankichi92/LiveLog.  
Please check out the [Contributing to LiveLog](https://github.com/sankichi92/LiveLog/blob/master/CONTRIBUTING.md) for guidelines about how to proceed.

Everyone interacting in the LiveLog project’s codebases, issue trackers, chat rooms and mailing lists is expected to follow the [code of conduct](https://github.com/sankichi92/LiveLog/blob/master/CODE_OF_CONDUCT.md).

## License

The application is available as open source under the terms of the [MIT License](http://opensource.org/licenses/MIT).
