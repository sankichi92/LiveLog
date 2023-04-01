# frozen_string_literal: true

Slack.configure do |config|
  config.token = ENV['SLACK_API_TOKEN']
  config.logger = Rails.logger
end

# https://github.com/slack-ruby/slack-ruby-client/issues/415
Slack::Web.configure do |config|
  config.ca_file = nil
  config.ca_path = nil
end
