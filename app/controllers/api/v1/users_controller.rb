class Api::V1::UsersController < Api::V1::ApplicationController
  before_action :check_public, only: :show

  def index
    @users = if params[:active] != 'true'
               User.natural_order
             else
               User.includes(songs: :live).where('lives.date': 1.year.ago..Time.zone.today).natural_order
             end
  end

  def show
    @playings = Playing.where(song_id: @user.songs.published.pluck('songs.id'))
  end

  private

  def check_public
    @user = User.includes(songs: :live).find(params[:id])
    request_http_token_authentication unless @user.public? || authenticated?
  end
end
