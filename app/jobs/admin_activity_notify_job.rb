class AdminActivityNotifyJob < ApplicationJob
  CHANNEL = if Rails.env.production?
              '#admin-activities'.freeze
            else
              '#sandbox'.freeze
            end

  queue_as :default

  def perform(user, text)
    Slack::Web::Client.new.chat_postMessage(
      channel: CHANNEL,
      text: text,
      username: user.member.name,
    )
  end
end
