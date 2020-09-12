# frozen_string_literal: true

class DeveloperActivityNotifyJob < ApplicationJob
  CHANNEL = if Rails.env.production?
              '#notif-developer'
            else
              '#sandbox'
            end

  queue_as :default

  def perform(user:, text:)
    Slack::Web::Client.new.chat_postMessage(
      channel: CHANNEL,
      text: text,
      username: user.member.joined_year_and_name,
    )
  end
end
