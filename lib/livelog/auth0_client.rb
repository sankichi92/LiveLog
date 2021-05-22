# frozen_string_literal: true

module LiveLog
  class Auth0Client
    include Singleton
    include Auth0::Mixins

    def initialize
      super(
        client_id: Rails.application.config.x.auth0.client_id,
        client_secret: Rails.application.config.x.auth0.client_secret,
        domain: Rails.application.config.x.auth0.domain,
      )
    end
  end
end
