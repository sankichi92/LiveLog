# frozen_string_literal: true

source 'https://rubygems.org'
git_source(:github) { |repo| "https://github.com/#{repo}.git" }

ruby '3.0.2'

gem 'rails', '~> 6.1.4'
# Use postgresql as the database for Active Record
gem 'pg', '~> 1.1'
# Use Puma as the app server
gem 'puma', '~> 5.4'
# Use SCSS for stylesheets
gem 'sass-rails', '>= 6'
# Reduces boot times through caching; required in config/boot.rb
gem 'bootsnap', '>= 1.4.4', require: false

gem 'action_args'
gem 'active_decorator'
gem 'acts_as_list'
gem 'auth0'
gem 'aws-sdk-s3', require: false
gem 'barnes'
gem 'cloudinary'
gem 'commonmarker'
gem 'dalli'
gem 'elasticsearch', '~> 7.13.3'
gem 'elasticsearch-dsl'
gem 'elasticsearch-rails', '~> 7.1.1'
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
gem 'ridgepole', require: false
gem 'scout_apm'
gem 'sentry-rails'
gem 'simpacker'
gem 'slack-ruby-client'
gem 'twitter'

# Must be after 'kaminari'
gem 'elasticsearch-model', '~> 7.1.1'

# API
gem 'graphql'
gem 'graphql-batch'
gem 'jwt'

group :development, :test do
  # Call 'byebug' anywhere in the code to stop execution and get a debugger console
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
  gem 'listen', '~> 3.7'
  # Access an interactive console on exception pages or by calling 'console' anywhere in the code.
  gem 'web-console', '>= 4.1.0'
  # Display performance information such as SQL time and flame graphs for each request in your browser.
  # Can be configured to work on production as well see: https://github.com/MiniProfiler/rack-mini-profiler/blob/master/README.md
  gem 'rack-mini-profiler', '~> 2.3'

  gem 'bullet'
  gem 'dotenv-rails'
  gem 'rails_real_favicon', require: false
end

group :test do
  # Adds support for Capybara system testing and selenium driver
  gem 'capybara', '>= 3.26'
  gem 'selenium-webdriver'
  # Easy installation and use of web drivers to run system tests with browsers
  gem 'webdrivers'

  gem 'webmock'
end
