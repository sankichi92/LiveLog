class AccountActivationsController < ApplicationController
  before_action :logged_in_user, only: [:new, :create]
  before_action :not_activated
  before_action :authenticated, only: [:edit, :update]

  def new
  end

  def create
    if @user.update_attributes(email: params[:user][:email])
      @user.create_activation_digest
      UserMailer.account_activation(@user).deliver_now
      flash[:success] = "#{@user.full_name}さんに招待メールを送信しました"
      redirect_to users_url
    else
      render 'new'
    end
  end

  def edit
  end

  def update
    if @user.update_attributes(params.require(:user).permit(:password, :password_confirmation))
      @user.update_attributes(activated: true, activated_at: Time.zone.now)
      log_in @user
      flash[:success] = 'Welcome to LiveLog!'
      redirect_to @user
    else
      render 'edit'
    end
  end

  private

  # Before filters

  def not_activated
    @user = User.find(params[:user_id])
    redirect_to(root_url) if @user.activated?
  end

  def authenticated
    unless @user.authenticated?(:activation, params[:t])
      flash[:danger] = '無効なリンクです'
      redirect_to(root_url)
    end
  end
end
