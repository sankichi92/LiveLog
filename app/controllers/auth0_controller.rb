class Auth0Controller < ApplicationController
  before_action :require_current_user, only: :logout

  def callback
    auth = request.env['omniauth.auth']
    livelog_id = Auth0User.extract_livelog_id(auth.uid)
    user = User.find(livelog_id)

    unless user.activated?
      user.activate!
      InvitationActivityNotifyJob.perform_later(user: user, text: "初めてログインしました")
    end

    # TODO: Remove this line after Auth0 migration finished.
    user.update!(password_digest: nil) unless user.password_digest.nil?

    log_in user

    redirect_to pop_stored_location || root_path, notice: 'ログインしました'
  rescue ActiveRecord::RecordNotFound => e
    Raven.capture_exception(e, extra: { auth0_id: request.env['omniauth.auth'].uid })
    redirect_to root_path, alert: 'ログインに失敗しました。管理者に問い合わせてください'
  end

  def failure(message, strategy)
    Raven.capture_message(message, extra: { strategy: strategy }, level: :debug)
    redirect_to root_path, alert: message
  end

  def logout
    log_out

    logout_uri = URI::HTTPS.build(
      host: ENV['AUTH0_DOMAIN'],
      path: '/v2/logout',
      query: { client_id: ENV['AUTH0_CLIENT_ID'] }.to_query,
    )
    redirect_to logout_uri.to_s, notice: 'ログアウトしました'
  end
end
