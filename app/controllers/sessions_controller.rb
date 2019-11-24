class SessionsController < ApplicationController
  before_action :require_current_user, only: :destroy

  def new; end

  def create(session)
    user = User.find_by(email: session[:email].downcase)

    if user.nil?
      flash.now.alert = '無効なメールアドレスとパスワードの組み合わせです'
      return render 'new', status: :unprocessable_entity
    end

    if user.authenticate(session[:password])
      log_in user
      session[:remember_me] == '1' ? remember(user) : forget(user)
      redirect_to pop_stored_location || member_path(user.member), notice: 'ログインしました'
    else
      flash.now.alert = '無効なメールアドレスとパスワードの組み合わせです'
      render 'new', status: :unprocessable_entity
    end
  end

  def destroy
    log_out
    redirect_to root_url, notice: 'ログアウトしました'
  end
end
