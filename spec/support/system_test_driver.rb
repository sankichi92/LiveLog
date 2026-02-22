# frozen_string_literal: true

RSpec.configure do |config|
  config.before type: :system do
    driven_by :rack_test
  end

  config.before type: :system, js: true do
    if ENV['USE_DOCKER_SELENIUM']
      # Keep these in sync so the remote browser reaches the same Capybara server.
      capybara_server_port = 4000
      capybara_app_host = "http://host.docker.internal:#{capybara_server_port}"

      Capybara.server_host = '0.0.0.0'
      Capybara.server_port = capybara_server_port
      Capybara.app_host = capybara_app_host
      driven_by :selenium, using: :headless_chrome, options: {
        browser: :remote,
        url: 'http://127.0.0.1:4444/wd/hub',
      }
    else
      driven_by :selenium, using: :headless_chrome
    end
  end
end
