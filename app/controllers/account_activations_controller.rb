class AccountActivationsController < ApplicationController
  before_action :logged_in_user, only: [:new, :create]
  before_action :not_activated

  def new
  end

  def create
    if @user.update_attributes(email: params[:user][:email])
      # UserMailer.account_activation(@user).deliver_now
      flash[:success] = "#{@user.full_name}さんに招待メールを送信しました"
      redirect_to users_url
    else
      render 'new'
    end
  end

  def edit

  end

  def update

  end

  private

  # Before filters

  def not_activated
    @user = User.find(params[:user_id])
    redirect_to(root_url) if @user.activated?
  end
end
