class SessionsController < ApplicationController
  before_action :logged_in_user, only: :destroy

  def new; end

  def create(session)
    user = User.find_by(email: session[:email].downcase)

    if user.nil?
      flash.now[:danger] = t('flash.controllers.sessions.invalid')
      return render 'new', status: :unprocessable_entity
    end

    unless user.activated?
      flash.now[:warning] = t('flash.controllers.sessions.inactivated')
      return render 'new', status: :unprocessable_entity
    end

    if user.authenticate(session[:password])
      log_in user
      session[:remember_me] == '1' ? remember(user) : forget(user)
      flash[:success] = t('flash.controllers.sessions.logged_in')
      redirect_back_or user
    else
      flash.now[:danger] = t('flash.controllers.sessions.invalid')
      render 'new', status: :unprocessable_entity
    end
  end

  def destroy
    log_out
    flash[:success] = t('flash.controllers.sessions.logged_out')
    redirect_to root_url
  end
end
