# frozen_string_literal: true

class DeveloperActivityNotifyJob < ApplicationJob
  queue_as :default

  def perform(user:, text:)
    Slack::Web::Client.new.chat_postMessage(
      channel: Rails.application.config.x.slack.notification_channel,
      text: text,
      username: user.member.joined_year_and_name,
    )
  end
end
