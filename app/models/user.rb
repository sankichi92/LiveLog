class User < ApplicationRecord
  self.ignored_columns = %i[email subscribing]

  belongs_to :member

  validate :admin_must_be_activated

  attr_accessor :email

  def self.find_auth0_id(auth0_id)
    id = auth0_id.match(/auth0\|(?<id>\d+)/)[:id]
    find(id)
  end

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
    @auth0_user ||= Auth0User.fetch!(id)
  rescue Auth0::NotFound => e # TODO: Remove this after Auth0 migration finished.
    Raven.capture_exception(e, extra: { user_id: id }, level: :info)
    Auth0User.new(id)
  end

  def create_auth0_user!(email: nil, password: nil)
    @auth0_user = Auth0User.create!(user: self, email: email || self.email, password: password)
  end

  def update_auth0_user!(options)
    Auth0User.new(id).update!(options)
  end

  def destroy_with_auth0_user!
    Auth0User.new(id).delete!
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
