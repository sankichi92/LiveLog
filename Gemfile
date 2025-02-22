# frozen_string_literal: true

source 'https://rubygems.org'

ruby '3.4.2'

# Bundle edge Rails instead: gem "rails", github: "rails/rails", branch: "main"
gem 'rails', '~> 8.0.1'
# The original asset pipeline for Rails [https://github.com/rails/sprockets-rails]
gem 'sprockets-rails'
# Use postgresql as the database for Active Record
gem 'pg', '~> 1.5'
# Use the Puma web server [https://github.com/puma/puma]
gem 'puma'
# Bundle and transpile JavaScript [https://github.com/rails/jsbundling-rails]
gem 'jsbundling-rails'
# Hotwire's modest JavaScript framework [https://stimulus.hotwired.dev]
gem 'stimulus-rails'

# Use SCSS for stylesheets
gem 'sassc-rails'

# Reduces boot times through caching; required in config/boot.rb
gem 'bootsnap', require: false

# Use Rack CORS for handling Cross-Origin Resource Sharing (CORS), making cross-origin Ajax possible
gem 'rack-cors'

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
gem 'graphiql-rails', '~> 1.8.0'
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
gem 'simple_oauth', require: false
gem 'slack-ruby-client'

# Must be after 'kaminari'
gem 'elasticsearch-model', '~> 7.1.1'

# API
gem 'graphql'
gem 'graphql-batch'
gem 'jwt'

group :development, :test do
  # See https://guides.rubyonrails.org/debugging_rails_applications.html#debugging-with-the-debug-gem
  gem 'debug', platforms: %i[mri windows], require: 'debug/prelude'

  gem 'bullet'
  gem 'factory_bot_rails'
  gem 'faker'
  gem 'rspec-rails'
  gem 'rubocop', require: false
  gem 'rubocop-capybara', require: false
  gem 'rubocop-factory_bot', require: false
  gem 'rubocop-graphql', require: false
  gem 'rubocop-rails', require: false
  gem 'rubocop-rspec', require: false
  gem 'rubocop-rspec_rails', require: false
end

group :development do
  # Use console on exceptions pages [https://github.com/rails/web-console]
  gem 'web-console'

  gem 'dotenv-rails'
  gem 'rails_real_favicon', require: false
end

group :test do
  # Use system testing [https://guides.rubyonrails.org/testing.html#system-testing]
  gem 'capybara'
  gem 'selenium-webdriver'

  gem 'webmock'
end
