Slack.configure do |config|
  config.token = ENV['SLACK_API_TOKEN']
  config.logger = Rails.logger
end
