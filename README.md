# LiveLog

https://livelog.ku-unplugged.net/

The [Ruby on Rails](https://rubyonrails.org/) application for set list management of the acoustic light music club "[京大アンプラグド](http://ku-unplugged.net/)."

## GraphQL API

Protected by OAuth 2.0.

- Endpoint: https://livelog.ku-unplugged.net/api/graphql
- GraphiQL: https://livelog.ku-unplugged.net/graphiql
- Authorization Server: https://patient-bar-7812.auth0.com/.well-known/openid-configuration
- Client Registration: https://livelog.ku-unplugged.net/clients/new
- Documentation: https://github.com/sankichi92/LiveLog/wiki

## Requirements

- [Ruby](https://www.ruby-lang.org/) 3.0
- [Node.js](https://nodejs.org/) & [Yarn](https://yarnpkg.com/)
- [PostgreSQL](https://www.postgresql.org/)
- [Elasticsearch](https://www.elastic.co/guide/en/elasticsearch/) 7.x
  - with [Japanese (kuromoji) Analysis Plugin](https://www.elastic.co/guide/en/elasticsearch/plugins/current/analysis-kuromoji.html)

If you're using macOS and [Homebrew](https://brew.sh/), you can setup them by the following commands:

    $ brew tap elastic/tap
    $ brew install rbenv yarn postgresql elastic/tap/elasticsearch-full
    $ rbenv install 3.0.2
    $ brew services start postgresql
    $ elasticsearch-plugin install analysis-kuromoji
    $ brew services restart elastic/tap/elasticsearch-full

## Development

### Clone the repository

    $ git clone https://github.com/sankichi92/LiveLog.git
    $ cd LiveLog

### Setup your development environment

    $ bin/setup

This script is idempotent, so that you can run it at anytime and get an expectable outcome.

### Run the app on your local web server

    $ bin/rails server

### Run the test suite

    $ bin/rails spec

### Lint and fix files

    $ bundle exec rubocop --auto-correct
    $ yarn run eslint --fix

### Create the first admin user

1. Sign up for [Auth0](https://auth0.com/) and create an application (regular web)
2. Overwrite `AUTH0_*` values in `.env` by your Auth0 application settings
3. Run `bin/rails db:seed:replant`

Then, you can log in by email `admin@example.com` and password `password`.

### Update DB schema

Edit `db/Schemafile` and run:

    $ bin/rake ridgepole:apply

### Rebuild Elasticsearch index

    $ bin/rake elasticsearch:import:song FORCE=y

### Enable to upload avatar images

1. Sign up for [Cloudinary](https://cloudinary.com/)
2. Overwrite `CLOUDINARY_URL` value in `.env`

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/sankichi92/LiveLog. This project is intended to be a safe, welcoming space for collaboration, and contributors are expected to adhere to the [code of conduct](https://github.com/sankichi92/LiveLog/blob/main/CODE_OF_CONDUCT.md).
