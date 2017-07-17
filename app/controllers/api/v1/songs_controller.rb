class Api::V1::SongsController < Api::V1::ApplicationController
  helper SongsHelper

  def index
    @songs = Song.includes(playings: :user).search(params[:q], params[:page])
  end

  def show
    @song = Song.includes(playings: :user).find(params[:id])
  end
end
