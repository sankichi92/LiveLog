# frozen_string_literal: true

source 'https://rubygems.org'

ruby '2.7.2'

gem 'rails'

gem 'pg'

gem 'puma'

gem 'sass-rails'
gem 'webpacker'

gem 'action_args'
gem 'active_decorator'
gem 'acts_as_list'
gem 'auth0'
gem 'aws-sdk-s3', require: false
gem 'bootsnap', require: false
gem 'cloudinary'
gem 'commonmarker'
gem 'elasticsearch', '~> 7.10'
gem 'elasticsearch-dsl'
gem 'elasticsearch-rails', '~> 7.0'
gem 'font-awesome-sass'
gem 'graphiql-rails'
gem 'haml-rails'
gem 'kaminari'
gem 'kaminari-i18n'
gem 'octokit'
gem 'omniauth'
gem 'omniauth-auth0'
gem 'omniauth-github'
gem 'omniauth-rails_csrf_protection'
gem 'rack-timeout'
gem 'rails-i18n'
gem 'redis'
gem 'ridgepole', require: false
gem 'sentry-rails'
gem 'slack-ruby-client'
gem 'twitter'

# Must be after 'kaminari'
gem 'elasticsearch-model', '~> 7.0'

# API
gem 'batch-loader'
gem 'graphql'
gem 'jwt'

group :development, :test do
  gem 'byebug', platforms: %i[mri mingw x64_mingw]

  gem 'factory_bot_rails'
  gem 'faker'
  gem 'rspec-rails'
  gem 'rubocop', require: false
  gem 'rubocop-performance', require: false
  gem 'rubocop-rails', require: false
  gem 'rubocop-rspec', require: false
  gem 'rubocop-rubycw', require: false
end

group :development do
  gem 'listen'
  gem 'spring'
  gem 'spring-watcher-listen'
  gem 'web-console'

  gem 'bullet'
  gem 'dotenv-rails'
  gem 'rails_real_favicon', require: false
end

group :test do
  gem 'capybara'
  gem 'selenium-webdriver'
  gem 'webdrivers'

  gem 'webmock'
end
