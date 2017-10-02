class Api::V1::SongsController < Api::V1::ApplicationController

  def index
    @songs = Song.performed.search(params[:q], params[:page])
  end

  def show
    @song = Song.includes(playings: :user).find(params[:id])
  end
end
