class ApplicationController < ActionController::Base
  include Pundit
  include Session

  before_action :set_raven_context

  rescue_from Pundit::NotAuthorizedError, with: :user_not_authorized

  private

  def set_raven_context
    Raven.user_context(id: current_user.id) if current_user
    Raven.extra_context(params: params.to_unsafe_h, url: request.url)
  end

  def user_not_authorized
    if current_user
      flash[:danger] = 'アクセス権がありません'
      redirect_back(fallback_location: root_url)
    else
      store_location
      flash[:danger] = 'ログインしてください'
      redirect_to login_url
    end
  end
end
