class Api::V1::SongsController < Api::V1::ApplicationController

  def index
    @songs = if params[:q].present?
               Song.search(params[:q]).page(params[:page]).records(includes: [:live, { playings: :user }])
             else
               Song.performed.includes(playings: :user).page(params[:page]).order_by_live
             end
  end

  def show
    @song = Song.includes(playings: :user).find(params[:id])
  end
end
