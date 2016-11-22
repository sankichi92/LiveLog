class PasswordResetsController < ApplicationController
  def new
  end

  def create
    @user = User.find_by(email: params[:password_reset][:email]).downcase)
    if @user
      @user.send_password_reset
      flash[:info] = 'パスワード再設定のためのメールを送信しました'
      redirect_to root_url
    else
      flash.now[:danger] = 'メールアドレスが見つかりませんでした'
      render 'new'
    end
  end

  def edit
  end
end
