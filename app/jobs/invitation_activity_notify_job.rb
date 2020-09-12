# frozen_string_literal: true

class InvitationActivityNotifyJob < ApplicationJob
  CHANNEL = if Rails.env.production?
              '#notif-invitation'
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
