RSpec.configure do |config|
  config.before type: :system do
    driven_by :rack_test
  end

  config.before type: :system, js: true do
    driven_by :selenium, using: :headless_chrome
  end
end
