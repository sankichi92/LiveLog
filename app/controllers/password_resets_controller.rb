class PasswordResetsController < ApplicationController
  permits :password, :password_confirmation, model_name: 'User'

  before_action :set_user, only: %i[edit update]
  before_action :valid_user, only: %i[edit update]
  before_action :check_expiration, only: %i[edit update]

  def new; end

  def create(password_reset)
    @user = User.find_by(email: password_reset[:email])
    if @user&.activated?
      @user.send_password_reset
      flash[:success] = t('flash.controllers.password_resets.sent')
      redirect_to root_url
    elsif @user.present?
      flash.now[:warning] = t('flash.controllers.password_resets.inactivated')
      render 'new', status: :unprocessable_entity
    else
      flash.now[:danger] = t('flash.controllers.password_resets.email_not_found')
      render 'new', status: :unprocessable_entity
    end
  end

  def edit; end

  def update(user)
    if user[:password].empty?
      @user.errors.add(:password, :blank)
      render 'edit', status: :unprocessable_entity
    elsif @user.reset_password(user)
      log_in @user
      flash[:success] = t('flash.controllers.password_resets.succeeded')
      redirect_to @user
    else
      render 'edit', status: :unprocessable_entity
    end
  end

  private

  def set_user(email = nil)
    if email.blank?
      flash[:danger] = t('flash.controllers.password_resets.invalid_url')
      redirect_to root_url
    else
      @user = User.find_by(email: email)
    end
  end

  def valid_user(id)
    redirect_to root_url unless @user&.activated? && @user.authenticated?(:reset, id)
  end

  def check_expiration
    return unless @user.password_reset_expired?
    flash[:danger] = t('flash.controllers.password_resets.token_expired')
    redirect_to new_password_reset_url
  end
end
