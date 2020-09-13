# frozen_string_literal: true

require 'app_auth0_client'

class User < ApplicationRecord
  SUPER_USER_ID = 1

  # self.ignored_columns = %i[subscribing]

  belongs_to :member
  has_one :auth0_credential, dependent: :destroy
  has_one :admin, dependent: :restrict_with_exception, class_name: 'Administrator'
  has_one :developer, dependent: :restrict_with_exception

  validates :email, presence: true, format: { with: URI::MailTo::EMAIL_REGEXP }, uniqueness: { case_sensitive: false }

  before_create :generate_auth0_id
  before_save { email.downcase! }

  scope :inactivated, -> { where(activated: false) }

  def save_credentials_and_userinfo!(credentials, userinfo)
    build_auth0_credential if auth0_credential.nil?

    self.email = userinfo[:email] if userinfo[:email].present? && userinfo[:email_verified]
    self.userinfo = userinfo.to_h

    transaction do
      auth0_credential.save_with_omniauth_credentials!(credentials)
      save!
    end
  end

  def activate!
    update!(activated: true)
  end

  def hide_ads?
    member.hide_ads? || id == SUPER_USER_ID
  end

  # region Auth0

  def fetch_auth0_user!
    Auth0User.fetch!(auth0_id)
  end

  def auth0_user
    @auth0_user ||= fetch_auth0_user!
  rescue Auth0::NotFound => e # TODO: Remove this after Auth0 migration finished.
    Raven.capture_exception(e, extra: { user_id: id }, level: :info)
    Auth0User.new({})
  end

  def invite!
    @auth0_user = begin
                    fetch_auth0_user!
                  rescue Auth0::NotFound
                    Auth0User.create!(self)
                  end

    if email != auth0_user.email
      update_auth0_user!(email: email, verify_email: false)
    end

    AppAuth0Client.instance.change_password(email, nil)
  end

  def update_auth0_user!(options)
    @auth0_user = Auth0User.update!(auth0_id, options)
  end

  def destroy_with_auth0_user!
    Auth0User.delete!(auth0_id)
    destroy!
  end

  # endregion

  private

  # region Callbacks

  def generate_auth0_id
    self.auth0_id ||= "auth0|#{SecureRandom.uuid}"
  end

  # endregion
end
