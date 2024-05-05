# frozen_string_literal: true

RSpec.configure do |config|
  config.before type: :system do
    driven_by :rack_test
  end

  config.before type: :system, js: true do
    options = ENV['SELENIUM_REMOTE'] ? { browser: :remote } : {}
    driven_by :selenium, using: :headless_chrome, options:
  end
end
