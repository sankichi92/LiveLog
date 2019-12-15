class EmailsController < ApplicationController
  before_action :require_current_user

  def show
    @auth0_user = current_user.auth0_user
  end

  def update(email, subscribing)
    @auth0_user = current_user.auth0_user

    if email.downcase != @auth0_user.email || !@auth0_user.email_verified?
      @auth0_user.update!(email: email, verify_email: true, user_metadata: { subscribing: subscribing == '1' })
      flash.notice = '確認メールを送信しました'
    else
      @auth0_user.update!(user_metadata: { subscribing: subscribing == '1' })
      flash.notice = '更新しました'
    end

    redirect_to email_path
  rescue Auth0::BadRequest => e
    Raven.capture_exception(e, level: :debug)
    @errors = ['メールアドレスが不正な値です']
    render :show, status: :unprocessable_entity
  end
end
