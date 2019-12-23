require 'app_auth0_client'

class Auth0User
  CONNECTION_NAME = 'Username-Password-Authentication'.freeze
  DEFAULT_FIELDS = %w[
    email
    email_verified
    user_metadata
    last_login
  ].join(',').freeze

  class << self
    def fetch!(id, fields: DEFAULT_FIELDS)
      response = AppAuth0Client.instance.user("auth0|#{id}", fields: fields)
      new(id, response)
    end

    def create!(user:, email:, password: nil)
      response = AppAuth0Client.instance.create_user(
        user.member.name,
        connection: CONNECTION_NAME,
        user_id: user.id.to_s,
        email: email,
        password: password ? password : ENV['AUTH0_CLIENT_SECRET'], # Prefix "0aA" is to pass the validation.
        verify_email: false,
        user_metadata: {
          livelog_member_id: user.member.id,
          joined_year: user.member.joined_year,
          subscribing: true,
        },
      )
      new(user.id, response)
    end
  end

  attr_reader :livelog_id

  def initialize(livelog_id, response = {})
    @livelog_id = livelog_id
    @response = response
  end

  def update!(options)
    AppAuth0Client.instance.patch_user("auth0|#{livelog_id}", options)
  end

  def delete!
    AppAuth0Client.instance.delete_user("auth0|#{livelog_id}")
  end

  def [](key)
    @response[key]
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

  def has_logged_in?
    !@response.dig('user_metadata', 'last_login').nil?
  end
end
