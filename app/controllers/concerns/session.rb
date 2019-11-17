module Session
  extend ActiveSupport::Concern

  included do
    helper_method :current_user
  end

  private

  # region Helpers

  def current_user
    if (user_id = session[:user_id])
      @current_user ||= User.find_by(id: user_id)
    elsif (user_id = cookies.signed[:user_id])
      user = User.find_by(id: user_id)
      if user && user.authenticated?(:remember, cookies[:remember_token])
        log_in user
        @current_user = user
      end
    end
  end

  # endregion

  # region Filters

  def require_current_user
    return if current_user

    store_location
    flash[:danger] = 'ログインしてください'
    redirect_to login_path
  end

  # endregion

  def log_in(user)
    session[:user_id] = user.id
  end

  def log_out
    forget(current_user)
    session.delete(:user_id)
    @current_user = nil
  end

  def remember(user)
    user.remember
    cookies.permanent.signed[:user_id] = user.id
    cookies.permanent[:remember_token] = user.remember_token
  end

  def forget(user)
    user.forget
    cookies.delete(:user_id)
    cookies.delete(:remember_token)
  end

  def store_location
    session[:forwarding_path] = request.fullpath if request.get?
  end

  def pop_stored_location
    session.delete(:forwarding_path)
  end
end
