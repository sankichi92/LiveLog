# frozen_string_literal: true

require 'app_auth0_client'

module Auth0UserHelper
  def stub_auth0_user(user, fields: Auth0User::DEFAULT_FIELDS, email_verified: true, email_accepting: true)
    allow(auth0_client_double).to receive(:user).with(
      user.auth0_id,
      fields: fields.join(','),
    ).and_return(
      {
        user_id: user.auth0_id,
        email: user.email,
        email_verified: email_verified,
        user_metadata: {
          livelog_email_notifications: email_accepting,
        },
        last_login: Time.zone.now.iso8601,
      }.deep_stringify_keys.slice(*fields),
    )
  end

  def auth0_client_double
    @auth0_client_double ||= double(:auth0_client).tap do |auth0_client|
      allow(AppAuth0Client).to receive(:instance).and_return(auth0_client)
    end
  end
end
