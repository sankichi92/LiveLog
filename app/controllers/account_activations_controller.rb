class AccountActivationsController < ApplicationController
  before_action :set_user
  before_action :check_inactivated, except: :destroy
  before_action :valid_user, only: %i[edit update]

  after_action :verify_authorized, except: %i[edit update]

  def new
    authorize @user, :invite?
  end

  def create(user)
    authorize @user, :invite?
    if @user.send_invitation(user[:email], current_user)
      flash[:success] = t('flash.controllers.account_activations.invited')
      redirect_to @user
    else
      render 'new', status: :unprocessable_entity
    end
  end

  def edit; end

  def update(user)
    if user[:password].empty?
      @user.errors.add(:password, :blank)
      render 'edit', status: :unprocessable_entity
    elsif @user.activate(user.permit(:password, :password_confirmation))
      log_in @user
      flash[:success] = t('flash.controllers.account_activations.activated')
      redirect_to @user
    else
      render 'edit', status: :unprocessable_entity
    end
  end

  def destroy
    authorize @user, :change_status?
    @user.deactivate
    flash[:success] = t('flash.controllers.account_activations.deactivated')
    redirect_to @user
  end

  private

  def set_user(user_id)
    @user = User.find(user_id)
  end

  def check_inactivated
    return unless @user.activated?
    flash[:info] = t('flash.controllers.account_activations.already_activated')
    redirect_to @user
  end

  def valid_user(t)
    return if @user.authenticated?(:activation, t)
    flash[:danger] = t('flash.controllers.account_activations.invalid_url')
    redirect_to root_url
  end
end
