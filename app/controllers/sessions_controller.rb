class SessionsController < ApplicationController

  def new
    #
  end

  def create
    user = User.find_by(email: params[:session][:email].downcase)
    if user&.activated?
      if user.authenticate(params[:session][:password])
        log_in user
        params[:session][:remember_me] == '1' ? remember(user) : forget(user)
        redirect_back_or user
      else
        flash.now[:danger] = '無効なメールアドレスとパスワードの組み合わせです'
        render 'new'
      end
    else
      flash[:warning] = 'アカウントが有効化されていません。メールを確認してください'
      redirect_to root_url
    end
  end

  def destroy
    log_out if logged_in?
    redirect_to root_url
  end
end
