class User < ApplicationRecord
  AlreadyCreatedError = Class.new(StandardError)

  self.ignored_columns = %i[email subscribing]

  belongs_to :member

  validates :email, format: { with: /[^\s]@[^\s]/ }, on: :create
  validate :admin_must_be_activated

  attr_accessor :email, :password

  def auth0_id
    "auth0|#{id}"
  end

  def activate!
    update!(activated: true)
  end

  def donated?
    donated_ids = ENV['LIVELOG_DONATED_USER_IDS']&.split(',')&.map(&:to_i) || []
    donated_ids.include?(id)
  end

  # region Auth0

  def auth0_user
    @auth0_user ||= Auth0User.fetch!(auth0_id)
  rescue Auth0::NotFound => e # TODO: Remove this after Auth0 migration finished.
    Raven.capture_exception(e, extra: { user_id: id }, level: :info)
    Auth0User.new({})
  end

  def create_with_auth0_user!
    raise AlreadyCreatedError, "User id #{id} is persisted" if persisted?

    transaction do
      save!
      @auth0_user = Auth0User.create!(self)
    end
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

  def admin_must_be_activated
    if admin? && !activated
      errors.add(:base, '管理者にするにはログイン済みでなければなりません')
    end
  end
end
