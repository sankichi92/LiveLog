class Api::V1::UsersController < Api::V1::ApplicationController

  def index
    if params[:active] != 'true'
      @users = User.natural_order
    else
      today  = Date.today
      range  = (today - 1.year..today)
      @users = User.natural_order.includes(songs: :live).where('lives.date' => range)
    end
  end

  def show
    @user = User.find(params[:id])
    @playings = Playing.where(song_id: @user.songs.pluck('songs.id'))
  end
end
