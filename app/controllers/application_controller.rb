class ApplicationController < ActionController::Base
  include Pundit
  include Session

  before_action :set_raven_context

  rescue_from Pundit::NotAuthorizedError, with: :user_not_authorized

  private

  def set_raven_context
    Raven.user_context(id: current_user.id, username: current_user.member.name) if current_user
    Raven.extra_context(params: params.to_unsafe_h, url: request.url)
  end

  def user_not_authorized
    if current_user
      redirect_back fallback_location: root_url, alert: 'アクセス権がありません'
    else
      store_location
      redirect_to login_url, alert: 'ログインしてください'
    end
  end
end
