class AccountActivationsController < ApplicationController
  before_action :logged_in_user, only: %i(new create)
  before_action :check_inactivated
  before_action :valid_user, only: %i(edit update)

  def new
  end

  def create
    if @user.send_invitation(params[:user][:email])
      flash[:info] = "招待メールを送信しました"
      redirect_to users_url
    else
      render 'new'
    end
  end

  def edit
  end

  def update
    if params[:user][:password].empty?
      @user.errors.add(:password, :blank)
      render 'edit'
    elsif @user.update_attributes(user_params)
      @user.activate
      log_in @user
      flash[:success] = 'Welcome to LiveLog!'
      redirect_to @user
    else
      render 'edit'
    end
  end

  private

  def user_params
    params.require(:user).permit(:password, :password_confirmation)
  end

  # Before filters

  def check_inactivated
    @user = User.find(params[:user_id])
    redirect_to(root_url) if @user.activated?
  end

  def valid_user
    unless @user.authenticated?(:activation, params[:t])
      flash[:danger] = '無効なリンクです'
      redirect_to(root_url)
    end
  end
end
