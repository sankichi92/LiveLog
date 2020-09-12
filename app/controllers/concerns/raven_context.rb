# frozen_string_literal: true

module RavenContext
  extend ActiveSupport::Concern

  included do
    before_action :set_raven_context
  end

  private

  def set_raven_context
    Raven.user_context(
      {
        id: current_user&.id,
        username: current_user&.member&.name,
        ip_address: request.ip,
      }.compact,
    )
  end
end
