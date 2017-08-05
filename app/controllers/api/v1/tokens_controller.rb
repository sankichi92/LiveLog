class Api::V1::TokensController < Api::V1::ApplicationController

  def create
    user = User.find_by(email: params[:email].downcase)
    if user && user.authenticate(params[:password])
      if user.activated?
        @token = User.new_token(urlsafe: false)
        user.update_attribute(:api_digest, User.digest(@token))
        @current_user = user
        render status: 201
      else
        render(
          status: 401
          plain: 'アカウントが有効化されていません。メールを確認してください',
        )
      end
    else
      render(
        status: 401
        plain: '無効なメールアドレスとパスワードの組み合わせです',
      )
    end
  end
end
