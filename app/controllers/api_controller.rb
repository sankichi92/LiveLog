# frozen_string_literal: true

class APIController < ActionController::API
  include JWTAuthentication
  include SentryUser

  before_action :set_api_raven_context

  private

  def set_api_raven_context
    Sentry.set_tags(client_id: current_client.id) if current_client
  end
end
