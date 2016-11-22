class AccountActivationsController < ApplicationController

  def create
    @user = User.find(params[:user][:id])
    if @user.update_attributes(email: params[:user][:email])
      # UserMailer.account_activation(@user).deliver_now
      flash[:success] = "#{@user.full_name}さんに招待メールを送信しました"
      redirect_to users_url
    else
      render template: 'users/invite'
    end
  end

  def edit

  end

  def update

  end
end
