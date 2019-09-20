RSpec.configure do |config|
  config.around elasticsearch: true do |example|
    Song.__elasticsearch__.create_index! force: true
    Song.__elasticsearch__.refresh_index!
    example.run
  ensure
    Song.__elasticsearch__.delete_index!
  end
end
