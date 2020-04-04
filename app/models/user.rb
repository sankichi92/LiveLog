require 'app_auth0_client'

class User < ApplicationRecord
  SUPER_ADMIN_ID = 1

  self.ignored_columns = %i[email subscribing]

  belongs_to :member
  has_many :user_registration_forms, dependent: :delete_all, foreign_key: 'admin_id', inverse_of: :admin

  attr_accessor :email, :password

  validates :email, format: { with: URI::MailTo::EMAIL_REGEXP }, on: :invite
  validate :admin_must_be_activated

  before_create :generate_auth0_id

  scope :inactivated, -> { where(activated: false) }

  def activate!
    update!(activated: true)
  end

  def hide_ads?
    member.hide_ads? || id == SUPER_ADMIN_ID
  end

  # region Auth0

  def auth0_user
    @auth0_user ||= fetch_auth0_user!
  rescue Auth0::NotFound => e # TODO: Remove this after Auth0 migration finished.
    Raven.capture_exception(e, extra: { user_id: id }, level: :info)
    Auth0User.new({})
  end

  def invite!
    validate!(:invite)

    @auth0_user = begin
                    fetch_auth0_user!
                  rescue Auth0::NotFound
                    Auth0User.create!(self)
                  end

    if email.downcase != auth0_user.email
      update_auth0_user!(email: email, verify_email: false)
    end

    AppAuth0Client.instance.change_password(email, nil)
  end

  def update_auth0_user!(options)
    Auth0User.update!(auth0_id, options)
  end

  def destroy_with_auth0_user!
    Auth0User.delete!(auth0_id)
    destroy!
  end

  # endregion

  private

  def fetch_auth0_user!
    Auth0User.fetch!(auth0_id)
  end

  # region Validations

  def admin_must_be_activated
    if admin? && !activated
      errors.add(:base, '管理者にするにはログイン済みでなければなりません')
    end
  end

  # endregion

  # region Callbacks

  def generate_auth0_id
    self.auth0_id ||= SecureRandom.uuid
  end

  # endregion
end
