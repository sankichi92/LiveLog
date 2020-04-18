class ClientsController < ApplicationController
  before_action :require_current_user, only: %i[new create]
  before_action :require_developer, only: %i[new create]

  permits :name, :app_type

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
      redirect_to clients_path, notice: 'アプリケーションを作成しました'
    else
      render :new, status: :unprocessable_entity
    end
  end

  private

  # region Filters

  def require_developer
    redirect_to clients_path, alert: '開発者登録してください' if current_user.developer.nil?
  end

  # endregion
end
