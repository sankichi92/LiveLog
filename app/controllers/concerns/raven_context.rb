module RavenContext
  extend ActiveSupport::Concern

  included do
    before_action :set_raven_context
  end

  private

  def set_raven_context
    Raven.user_context(id: current_user.id, username: current_user.member.name) if current_user
    Raven.extra_context(params: params.to_unsafe_h, url: request.url)
  end
end
