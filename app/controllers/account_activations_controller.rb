class AccountActivationsController < ApplicationController
  before_action :logged_in_user, only: %i[new create]
  before_action :set_user
  before_action :check_inactivated, except: :destroy
  before_action :valid_user, only: %i[edit update]

  def new
    #
  end

  def create
    if @user.send_invitation(params[:user][:email], current_user)
      flash[:success] = '招待メールを送信しました'
      redirect_to users_url
    else
      render 'new'
    end
  end

  def edit
    #
  end

  def update
    if params[:user][:password].empty?
      @user.errors.add(:password, :blank)
      render 'edit'
    elsif @user.activate(user_params)
      log_in @user
      flash[:success] = 'LiveLog へようこそ！'
      redirect_to @user
    else
      render 'edit'
    end
  end

  def destroy
    @user.deactivate
    flash[:success] = 'アカウントを無効にしました'
    redirect_to @user
  end

  private

  # Before filters

  def set_user
    @user = User.find(params[:user_id])
  end

  def check_inactivated
    redirect_to root_url if @user.activated?
  end

  def valid_user
    return if @user.authenticated?(:activation, params[:t])
    flash[:danger] = '無効なリンクです'
    redirect_to root_url
  end

  # Strong parameters

  def user_params
    params.require(:user).permit(:password, :password_confirmation)
  end
end
