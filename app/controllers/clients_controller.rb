class ClientsController < ApplicationController
  before_action :require_current_user, only: %i[new create edit update destroy]
  before_action :require_developer, only: %i[new create]
  before_action :require_owner, only: %i[edit update destroy]

  permits :name, :description, :logo_url, :app_type, :callback_url, :login_url, :logout_url, :allowed_origin, :jwt_signature_alg

  def new
    @client = Client.new
  end

  def create(client)
    @client = Client.new(client)
    @client.developer = current_user.developer
    github_user = current_user.developer.fetch_github_user!
    @client.logo_url = github_user[:avatar_url]

    if @client.valid?
      @client.create_auth0_client!
      @client.create_livelog_grant!
      DeveloperActivityNotifyJob.perform_later(user: current_user, text: "アプリケーションを作成しました: #{@client.name}")
      redirect_to edit_client_path(@client), notice: 'アプリケーションを作成しました'
    else
      render :new, status: :unprocessable_entity
    end
  rescue Octokit::Unauthorized
    redirect_to developer_path, alert: 'GitHub アカウントを再連携してください'
  end

  def edit
  end

  def update(client)
    @client.assign_attributes(client)

    if @client.valid? && @client.update_auth0_client
      @client.save!
      redirect_to edit_client_path(@client), notice: '更新しました'
    else
      render :edit, status: :unprocessable_entity
    end
  end

  def destroy
    @client.destroy_with_auth0_client!
    DeveloperActivityNotifyJob.perform_later(user: current_user, text: "アプリケーションを削除しました: #{@client.name}")
    redirect_to developer_path, notice: "#{@client.name} を削除しました"
  end

  private

  # region Filters

  def require_developer
    redirect_to developer_path, alert: '開発者登録してください' if current_user.developer.nil? || current_user.developer.github_access_token.nil?
  end

  def require_owner(id)
    @client = Client.find(id)
    redirect_to developer_path, alert: '権限がありません' if current_user != @client.developer.user
  end

  # endregion
end
