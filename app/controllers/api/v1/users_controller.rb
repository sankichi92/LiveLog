class Api::V1::UsersController < Api::V1::ApplicationController
  before_action :check_public, only: :show

  def index
    if params[:active] != 'true'
      @users = User.natural_order
    else
      today  = Time.zone.today
      range  = (today - 1.year..today)
      @users = User.natural_order.includes(songs: :live).where('lives.date' => range)
    end
  end

  def show
    @playings = Playing.where(song_id: @user.songs.pluck('songs.id'))
  end

  private

  def check_public
    @user = User.includes(songs: :live).find(params[:id])
    request_http_token_authentication unless @user.public? || authenticated?
  end
end
