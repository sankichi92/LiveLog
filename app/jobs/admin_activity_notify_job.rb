# frozen_string_literal: true

class AdminActivityNotifyJob < ApplicationJob
  queue_as :default

  def perform(user:, operation:, object:, detail: nil, url: nil)
    Slack::Web::Client.new.chat_postMessage(
      channel: ENV.fetch('SLACK_NOTIFICATION_CHANNEL', '#notif-admin'),
      blocks: build_blocks(operation, object, detail, url),
      username: user.member.joined_year_and_name,
    )
  end

  private

  def build_blocks(operation, object, detail, url)
    blocks = []

    blocks << {
      type: 'section',
      text: {
        type: 'mrkdwn',
        text: "*#{object.class.model_name.human} #{object.id}*: #{operation}",
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

    if url.present?
      blocks << {
        type: 'context',
        elements: [
          {
            type: 'mrkdwn',
            text: "<#{url}>",
          },
        ],
      }
    end

    blocks
  end
end
