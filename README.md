# LiveLog

https://livelog.ku-unplugged.net/

The Ruby on Rails application to manage set lists of the acoustic light music club "[京大アンプラグド](http://ku-unplugged.net/)."

## Requirements

- Ruby 2.6
- Node.js
- PostgreSQL
- [Elasticsearch](https://www.elastic.co/guide/en/elasticsearch/reference/current/install-elasticsearch.html) 6.x
  - with [Japanese (kuromoji) Analysis Plugin](https://www.elastic.co/guide/en/elasticsearch/plugins/current/analysis-kuromoji.html)
- [ImageMagick](https://imagemagick.org/)

## Development

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
