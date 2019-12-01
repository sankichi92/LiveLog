require 'app_auth0_client'

class User < ApplicationRecord
  AUTH0_UP_AUTH_CONNECTION = 'Username-Password-Authentication'.freeze

  self.ignored_columns = %i[remember_digest reset_digest reset_sent_at]

  has_secure_password validations: false

  has_one :member, dependent: :nullify

  before_save :downcase_email

  def self.find_auth0_id(auth0_id)
    id = auth0_id.match(/auth0\|(?<id>\d+)/)[:id]
    find(id)
  end

  # region Attributes

  def auth0_id
    "auth0|#{id}"
  end

  # endregion

  # region Status

  def activate!
    update!(activated: true)
  end

  def donated?
    donated_ids = ENV['LIVELOG_DONATED_USER_IDS']&.split(',')&.map(&:to_i) || []
    donated_ids.include?(id)
  end

  # endregion

  # region Auth0

  def auth0_user
    @auth0_user ||= fetch_auth0_user!
  end

  def fetch_auth0_user!
    @auth0_user = AppAuth0Client.instance.user(auth0_id)
  end

  def create_auth0_user!(email)
    @auth0_user = AppAuth0Client.instance.create_user(
      member.name,
      connection: AUTH0_UP_AUTH_CONNECTION,
      user_id: id.to_s,
      email: email,
      password: "0aA#{SecureRandom.base58}", # Prefix "0aA" is to pass the validation.
      verify_email: false,
      user_metadata: {
        livelog_member_id: member.id,
        joined_year: member.joined_year,
        subscribing: subscribing,
      },
    )
  end

  def update_auth0_user!(options)
    AppAuth0Client.instance.patch_user(auth0_id, options)
  end

  # endregion

  private

  def downcase_email
    self.email = email.downcase unless email.nil?
  end
end
