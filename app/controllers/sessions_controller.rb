class SessionsController < ApplicationController

  def new
    #
  end

  def create
    user = User.find_by(email: params[:session][:email].downcase)

    if user.nil?
      flash.now[:danger] = '無効なメールアドレスとパスワードの組み合わせです'
      return render 'new'
    end

    unless user.activated?
      flash[:warning] = 'アカウントが有効化されていません。メールを確認してください'
      return redirect_to root_url
    end

    if user.authenticate(params[:session][:password])
      log_in user
      params[:session][:remember_me] == '1' ? remember(user) : forget(user)
      redirect_back_or user
    else
      flash.now[:danger] = '無効なメールアドレスとパスワードの組み合わせです'
      render 'new'
    end
  end

  def destroy
    log_out if logged_in?
    redirect_to root_url
  end
end
