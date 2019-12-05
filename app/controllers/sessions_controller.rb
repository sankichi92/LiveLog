class SessionsController < ApplicationController
  before_action :require_current_user, only: :destroy

  def create
    auth = request.env['omniauth.auth']
    user = User.find_auth0_id(auth.uid)

    user.activate! unless user.activated?

    # TODO: Remove this line after Auth0 migration finished.
    user.update!(email: nil, password_digest: nil) if !user.email.nil? || !user.password_digest.nil?

    log_in user

    redirect_to pop_stored_location || root_path, notice: 'ログインしました'
  rescue ActiveRecord::RecordNotFound => e
    Raven.capture_exception(e, extra: { auth0_id: request.env['omniauth.auth'].uid })
    redirect_to root_path, alert: 'ログインに失敗しました。管理者に問い合わせてください'
  end

  def failure(message, strategy)
    Raven.capture_message(message, extra: { strategy: strategy }, level: :warn)
    redirect_to root_path, alert: message
  end

  def destroy
    log_out

    logout_uri = URI::HTTPS.build(
      host: ENV['AUTH0_DOMAIN'],
      path: '/v2/logout',
      query: { client_id: ENV['AUTH0_CLIENT_ID'] }.to_query,
    )
    redirect_to logout_uri.to_s, notice: 'ログアウトしました'
  end
end
