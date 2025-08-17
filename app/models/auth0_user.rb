# frozen_string_literal: true

require 'livelog/auth0_client'

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
      response = LiveLog::Auth0Client.instance.user(auth0_id, fields: fields.join(','))
      new(response)
    end

    def create!(user, password: "0aA#{SecureRandom.base58}")
      response = LiveLog::Auth0Client.instance.create_user(
        CONNECTION_NAME,
        user_id: user.auth0_id[/\Aauth0\|(\S+)/, 1],
        name: user.member.name,
        email: user.email,
        password:,
        verify_email: false,
        picture: user.member.avatar&.image_url(size: :medium),
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
      response = LiveLog::Auth0Client.instance.patch_user(auth0_id, options)
      new(response)
    end

    def delete!(auth0_id)
      LiveLog::Auth0Client.instance.delete_user(auth0_id)
    end
  end

  def initialize(response)
    @response = response
  end

  delegate :[], to: :@response

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

  def has_logged_in? # rubocop:disable Naming/PredicatePrefix
    !@response['last_login'].nil?
  end

  def update!(options)
    self.class.update!(id, options)
  end
end
