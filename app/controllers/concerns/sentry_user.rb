# frozen_string_literal: true

module SentryUser
  extend ActiveSupport::Concern

  included do
    before_action :set_sentry_user
  end

  private

  def set_sentry_user
    Sentry.set_user(
      {
        id: current_user&.id,
        username: current_user&.member&.name,
        ip_address: request.ip,
      }.compact,
    )
  end
end
