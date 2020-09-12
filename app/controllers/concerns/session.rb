# frozen_string_literal: true

module Session
  extend ActiveSupport::Concern

  included do
    helper_method :current_user
  end

  private

  # region Helpers

  def current_user
    @current_user ||= if session[:user_id]
                        User.find_by(id: session[:user_id])
                      end
  end

  # endregion

  # region Filters

  def require_current_user
    return if current_user

    store_location
    redirect_to root_path, alert: 'ログインしてください'
  end

  # endregion

  def log_in(user)
    session[:user_id] = user.id
  end

  def log_out
    @current_user = nil
    reset_session
  end

  def store_location
    session[:forwarding_path] = request.fullpath if request.get?
  end

  def pop_stored_location
    session.delete(:forwarding_path)
  end
end
