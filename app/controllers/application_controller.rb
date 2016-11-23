class ApplicationController < ActionController::Base
  protect_from_forgery with: :exception
  include SessionsHelper

  protected

  def logged_in_user
    unless logged_in?
      store_location
      flash[:danger] = 'ログインしてください'
      redirect_to login_url
    end
  end

  def admin_user
    logged_in_user
    redirect_to(root_url) unless current_user.admin?
  end

  def admin_or_elder_user
    admin_user
    redirect_to(root_url) unless current_user.elder?
  end
end
