class ApplicationController < ActionController::Base
  protect_from_forgery with: :exception
  before_action :set_raven_context

  include SessionsHelper

  private

  def set_raven_context
    Raven.user_context(id: current_user.id, name: current_user.name, admin?: current_user.admin?) if logged_in?
    Raven.extra_context(params: params.to_unsafe_h, url: request.url)
  end

  # Before filters

  def logged_in_user
    return if logged_in?
    store_location
    flash[:danger] = 'ログインしてください'
    redirect_to login_url
  end

  def admin_user
    redirect_to root_url unless current_user.admin?
  end

  def admin_or_elder_user
    redirect_to root_url unless current_user.admin_or_elder?
  end
end
