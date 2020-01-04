class EntryActivityNotifyJob < ApplicationJob
  CHANNEL = if Rails.env.production?
              '#notif-entry'.freeze
            else
              '#sandbox'.freeze
            end

  queue_as :default

  def perform(user:, operation:, entry_id:, detail:)
    Slack::Web::Client.new.chat_postMessage(
      channel: CHANNEL,
      blocks: build_blocks(operation, entry_id, detail),
      username: user.member.joined_year_and_name,
    )
  end

  private

  def build_blocks(operation, entry_id, detail)
    blocks = []

    blocks << {
      type: 'section',
      text: {
        type: 'mrkdwn',
        text: "*ID: #{entry_id}* #{operation}",
      },
    }

    if detail.present?
      blocks << {
        type: 'section',
        text: {
          type: 'mrkdwn',
          text: "```#{JSON.pretty_generate(detail)}```",
        },
      }
    end

    blocks
  end
end
