require 'app_auth0_client'

class AuthController < ApplicationController
  before_action :require_current_user, only: :logout

  def auth0
    auth = request.env['omniauth.auth']
    user = User.find_by!(auth0_id: auth.uid)

    user.save_credentials_and_userinfo!(auth.credentials, auth.extra.raw_info)

    unless user.activated?
      user.activate!
      InvitationActivityNotifyJob.perform_later(user: user, text: '初めてログインしました')
    end

    # TODO: Remove this line after Auth0 migration finished.
    user.update!(password_digest: nil) unless user.password_digest.nil?

    log_in user

    redirect_to pop_stored_location || root_path, notice: 'ログインしました'
  rescue ActiveRecord::RecordNotFound => e
    Raven.capture_exception(e, extra: { auth0_id: request.env['omniauth.auth'].uid })
    redirect_to root_path, alert: 'ログインに失敗しました。管理者に問い合わせてください'
  end

  def github
    auth = request.env['omniauth.auth']

    if current_user.nil?
      Raven.capture_message('Attempt to create a developer without log-in', extra: { github_username: auth.info.nickname }, level: :warning)
      redirect_to root_path, alert: 'ログインしてください'
    else
      developer = current_user.developer || current_user.build_developer
      developer.update!(
        github_id: auth.uid,
        github_username: auth.info.nickname,
        github_access_token: auth.credentials.token,
      )
      DeveloperActivityNotifyJob.perform_later(user: current_user, text: "開発者登録しました: #{auth.info.nickname}")
      redirect_to developer_path, notice: '開発者登録しました'
    end
  end

  def failure(message, strategy)
    Raven.capture_message(message, extra: { strategy: strategy }, level: :debug)
    redirect_to root_path, alert: message
  end

  def logout
    log_out

    logout_uri = AppAuth0Client.instance.logout_url(root_url, include_client: true)
    redirect_to logout_uri.to_s, notice: 'ログアウトしました'
  end
end
