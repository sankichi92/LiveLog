# LiveLog

[![Build Status](https://travis-ci.org/sankichi92/LiveLog.svg?branch=master)](https://travis-ci.org/sankichi92/LiveLog)

This is the application to manage set lists of the acoustic light music club "[KU Unplugged (京大アンプラグド)](http://ku-unplugged.net/)."

![Logo](app/assets/images/logo.png)

## Getting started

To get started with the app, clone the repo and then install the needed gems:

```
$ bundle install --without production
```

Next, migrate the database:

```
$ rails db:migrate
```

Finally, run the test suite to verify that everything is working correctly:

```
$ rails spec
```

If the test suite passes, you'll be ready to run the app in a local server:

```
$ rails server
```

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/sankichi92/LiveLog2.
This project is intended to be a safe, welcoming space for collaboration, and contributors are expected to adhere to the [Contributor Covenant](http://contributor-covenant.org) code of conduct.

## License

The application is available as open source under the terms of the [MIT License](http://opensource.org/licenses/MIT).

