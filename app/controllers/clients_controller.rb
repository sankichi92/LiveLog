class ClientsController < ApplicationController
  before_action :require_current_user, only: %i[new create edit update]
  before_action :require_developer, only: %i[new create]
  before_action :require_owner, only: %i[edit update]

  permits :name, :description, :url, :logo_url, :app_type, :callback_url, :login_url, :logout_url, :allowed_origin

  def index
    @clients = Client.includes(developer: { user: :member }).reverse_order
  end

  def new
    @client = current_user.developer.clients.build
  end

  def create(client)
    @client = current_user.developer.clients.build(client)

    if @client.valid?
      @client.create_auth0_client!
      @client.create_livelog_grant!
      redirect_to edit_client_path(@client), notice: 'アプリケーションを作成しました'
    else
      render :new, status: :unprocessable_entity
    end
  end

  def edit
  end

  def update(client)
    @client.assign_attributes(client)

    if @client.valid? && @client.update_auth0_client!
      @client.save!
      redirect_to edit_client_path(@client), notice: '更新しました'
    else
      render :edit, status: :unprocessable_entity
    end
  end

  private

  # region Filters

  def require_developer
    redirect_to clients_path, alert: '開発者登録してください' if current_user.developer.nil?
  end

  def require_owner(id)
    @client = Client.find(id)
    redirect_to clients_path, alert: '権限がありません' if current_user != @client.developer.user
  end

  # endregion
end
