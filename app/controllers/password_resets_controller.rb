class PasswordResetsController < ApplicationController
  before_action :set_user, only: %i[edit update]
  before_action :valid_user, only: %i[edit update]
  before_action :check_expiration, only: %i[edit update]

  def new
    #
  end

  def create
    @user = User.find_by(email: params[:password_reset][:email].downcase)
    if @user
      @user.send_password_reset
      flash[:success] = 'パスワード再設定のためのメールを送信しました'
      redirect_to root_url
    else
      flash.now[:danger] = 'メールアドレスが見つかりませんでした'
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
    elsif @user.reset_password(user_params)
      log_in @user
      flash[:success] = 'パスワードが再設定されました'
      redirect_to @user
    else
      render 'edit'
    end
  end

  private

  # Before filters

  def set_user
    @user = User.find_by(email: params[:email])
  end

  def valid_user
    redirect_to root_url unless @user && @user.activated? && @user.authenticated?(:reset, params[:id])
  end

  def check_expiration
    return unless @user.password_reset_expired?
    flash[:danger] = 'パスワード再設定の有効期限が過ぎてきます'
    redirect_to new_password_reset_url
  end

  # Strong parameters

  def user_params
    params.require(:user).permit(:password, :password_confirmation)
  end
end
