# frozen_string_literal: true

require 'app_auth0_client'

module API
  class ScopesController < APIController
    skip_before_action :authenticate_with_jwt

    def index
      resource_server = Rails.cache.fetch('api/scopes', expires_in: 10.minutes) do
        AppAuth0Client.instance.resource_server(Rails.application.config.x.auth0.resource_server_id)
      end
      render json: resource_server['scopes']
    end
  end
end
