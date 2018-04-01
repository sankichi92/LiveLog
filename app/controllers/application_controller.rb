class ApplicationController < ActionController::Base
  include SessionsHelper
  include Pundit

  protect_from_forgery with: :exception

  before_action :set_raven_context

  rescue_from Pundit::NotAuthorizedError, with: :user_not_authorized

  private

  def set_raven_context
    Raven.user_context(id: current_user.id, name: current_user.name, admin?: current_user.admin?) if logged_in?
    Raven.extra_context(params: params.to_unsafe_h, url: request.url)
  end

  def user_not_authorized
    if logged_in?
      flash[:danger] = 'アクセス権がありません'
      redirect_back(fallback_location: root_url)
    else
      store_location
      flash[:danger] = 'ログインしてください'
      redirect_to login_url
    end
  end

  # region Before filters

  def logged_in_user
    return if logged_in?
    store_location
    flash[:danger] = 'ログインしてください'
    redirect_to login_url
  end

  # endregion
end
