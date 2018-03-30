class SessionsController < ApplicationController
  before_action :logged_in_user, only: :destroy

  def new; end

  def create(session)
    user = User.find_by(email: session[:email].downcase)

    if user.nil?
      flash.now[:danger] = t('login.invalid')
      return render 'new', status: :unprocessable_entity
    end

    unless user.activated?
      flash.now[:warning] = t('login.inactivated')
      return render 'new', status: :unprocessable_entity
    end

    if user.authenticate(session[:password])
      log_in user
      session[:remember_me] == '1' ? remember(user) : forget(user)
      flash[:success] = t('login.success')
      redirect_back_or user
    else
      flash.now[:danger] = t('login.invalid')
      render 'new', status: :unprocessable_entity
    end
  end

  def destroy
    log_out
    flash[:success] = t(:logout)
    redirect_to root_url
  end
end
