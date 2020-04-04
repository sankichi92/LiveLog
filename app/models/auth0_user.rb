require 'app_auth0_client'

class Auth0User
  CONNECTION_NAME = 'Username-Password-Authentication'.freeze
  DEFAULT_FIELDS = %w[
    user_id
    email
    email_verified
    user_metadata
    last_login
  ].join(',').freeze

  class << self
    def fetch!(auth0_id, fields: DEFAULT_FIELDS)
      response = AppAuth0Client.instance.user(auth0_id, fields: fields)
      new(response)
    end

    def create!(user)
      response = AppAuth0Client.instance.create_user(
        user.member.name,
        connection: CONNECTION_NAME,
        user_id: user.auth0_id,
        email: user.email,
        password: user.password.presence || "0aA#{SecureRandom.base58}", # Prefix "0aA" is to pass the validation.
        verify_email: false,
        user_metadata: {
          livelog_member_id: user.member.id,
          joined_year: user.member.joined_year,
          subscribing: true,
        },
      )
      new(response)
    end

    def update!(auth0_id, options)
      AppAuth0Client.instance.patch_user(auth0_id, options)
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

  def subscribing?
    @response.dig('user_metadata', 'subscribing')
  end

  def email_verified_and_subscribing?
    email_verified? && subscribing?
  end

  def has_logged_in?
    !@response['last_login'].nil?
  end

  def update!(options)
    self.class.update!(id, options)
  end
end
