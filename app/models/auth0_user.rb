# frozen_string_literal: true

require 'app_auth0_client'

class Auth0User
  CONNECTION_NAME = 'Username-Password-Authentication'
  DEFAULT_FIELDS = %w[
    user_id
    email
    email_verified
    user_metadata
    last_login
  ].freeze

  class << self
    def fetch!(auth0_id, fields: DEFAULT_FIELDS)
      response = AppAuth0Client.instance.user(auth0_id, fields: fields.join(','))
      new(response)
    end

    def create!(user, password: "0aA#{SecureRandom.base58}")
      response = AppAuth0Client.instance.create_user(
        user.member.name,
        connection: CONNECTION_NAME,
        user_id: user.auth0_id[/\Aauth0\|(\S+)/, 1],
        email: user.email,
        password: password,
        verify_email: false,
        user_metadata: {
          livelog_email_notifications: true,
        },
        app_metadata: {
          joined_year: user.member.joined_year,
          livelog_member_id: user.member.id,
        },
      )
      new(response)
    end

    def update!(auth0_id, options)
      response = AppAuth0Client.instance.patch_user(auth0_id, options)
      new(response)
    end

    def delete!(auth0_id)
      AppAuth0Client.instance.delete_user(auth0_id)
    end
  end

  def initialize(response)
    @response = response
  end

  def [](key)
    @response[key]
  end

  def id
    @response['user_id']
  end

  def email
    @response['email']
  end

  def email_verified?
    @response['email_verified']
  end

  def email_accepting?
    @response.dig('user_metadata', 'livelog_email_notifications')
  end

  def email_verified_and_accepting?
    email_verified? && email_accepting?
  end

  def has_logged_in? # rubocop:disable Naming/PredicateName
    !@response['last_login'].nil?
  end

  def update!(options)
    self.class.update!(id, options)
  end
end
