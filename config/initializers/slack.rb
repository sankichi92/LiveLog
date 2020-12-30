# frozen_string_literal: true

Slack.configure do |config|
  config.token = ENV['SLACK_API_TOKEN']
  config.logger = Rails.logger
end

Rails.application.config.x.slack.notification_channel = ENV.fetch('SLACK_NOTIFICATION_CHANNEL', '#sandbox')
