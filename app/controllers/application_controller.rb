class ApplicationController < ActionController::Base
  protect_from_forgery with: :exception
  before_action :set_raven_context
  rescue_from User::NotAuthorized, with: :user_not_authorized

  include SessionsHelper

  private

  def set_raven_context
    Raven.user_context(id: current_user.id, name: current_user.name, admin?: current_user.admin?) if logged_in?
    Raven.extra_context(params: params.to_unsafe_h, url: request.url)
  end

  # region Before filters

  def logged_in_user
    raise User::NotAuthorized unless logged_in?
  end

  def admin_user
    raise User::NotAuthorized unless current_user&.admin?
  end

  def admin_or_elder_user
    raise User::NotAuthorized unless current_user&.admin_or_elder?
  end

  def store_referer
    session[:forwarding_url] = request.referer || root_url
  end

  # endregion

  # region Rescue

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

  # endregion
end
