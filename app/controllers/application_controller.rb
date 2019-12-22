class ApplicationController < ActionController::Base
  include Pundit
  include Session
  include RavenContext

  rescue_from Pundit::NotAuthorizedError, with: :user_not_authorized

  private

  def user_not_authorized
    if current_user
      redirect_back fallback_location: root_url, alert: 'アクセス権がありません'
    else
      store_location
      redirect_to login_url, alert: 'ログインしてください'
    end
  end
end
