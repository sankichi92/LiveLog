source 'https://rubygems.org'

ruby '2.6.3'

gem 'rails', '~> 5.2.3'

gem 'pg', '~> 1.1'

gem 'will_paginate', '~> 3.1.8' # must be added before the Elasticsearch gems
gem 'elasticsearch', '~> 6.1'
gem 'elasticsearch-rails', '~> 6.1'
gem 'elasticsearch-model', '~> 6.1'
gem 'elasticsearch-dsl', '~> 0.1'

gem 'action_args', '~> 2.4.0'
gem 'active_decorator', '~> 1.3.1'
gem 'aws-sdk-s3', '~> 1.46.0', require: false
gem 'bcrypt', '~> 3.1.13'
gem 'bootsnap', '>= 1.1.0', require: false
gem 'bootstrap', '~> 4.3'
gem 'bootstrap-will_paginate', '~> 1.0.0'
gem 'font-awesome-sass', '~> 5.9.0'
gem 'haml-rails', '~> 2.0'
gem 'jbuilder', '~> 2.9'
gem 'jquery-rails'
gem 'mini_magick', '~> 4.9'
gem 'omniauth', '~> 1.9.0'
gem 'omniauth-google-oauth2', '~> 0.8.0'
gem 'puma', '~> 4.1'
gem 'pundit', '~> 2.1'
gem 'redis', '~> 4.1.2'
gem 'sass-rails', '~> 6.0'
gem 'select2-rails', '~> 4.0.3'
gem 'sentry-raven'
gem 'turbolinks', '~> 5'
gem 'twitter', '~> 6.2'
gem 'uglifier', '>= 3.2.0'

group :development, :test do
  gem 'byebug', platform: :mri
  gem 'faker'
  gem 'rspec-rails', '~> 3.8'
end

group :development do
  gem 'better_errors'
  gem 'binding_of_caller'
  gem 'haml_lint', require: false
  gem 'listen', '~> 3.1.5'
  gem 'meowcop', require: false
  gem 'rails_real_favicon'
  gem 'spring'
  gem 'spring-watcher-listen', '~> 2.0.1'
  gem 'web-console', '>= 3.5.1'
end

group :test do
  gem 'capybara', '~> 3.28'
  gem 'factory_bot_rails', '~> 5.0'
  gem 'rspec-json_matcher', '~> 0.1.6'
  gem 'selenium-webdriver', '~> 3.142'
  gem 'webdrivers', '~> 4.1'
end

group :production do
  gem 'newrelic_rpm'
end

gem 'tzinfo-data', platforms: %i[mingw mswin x64_mingw jruby]
