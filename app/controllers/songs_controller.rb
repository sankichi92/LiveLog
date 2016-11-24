class SongsController < ApplicationController
  before_action :logged_in_user
  before_action :admin_or_elder_user, only: %i(new create destroy)
  before_action :set_song, only: %i(show edit update destroy)

  def show
  end

  def new
    live = params[:live_id] ? Live.find(params[:live_id]) : Live.first
    @song = live.songs.build
  end

  def create
    @song = Song.new(song_params)
    if @song.save
      flash[:success] = '曲を追加しました'
      redirect_to @song.live
    else
      render :new
    end
  end

  def edit
  end

  def update
  end

  def destroy
  end

  private

  def set_song
    @song = Song.find(params[:id])
  end

  def song_params
    params.require(:song).permit(:live_id, :time, :order, :name, :artist, :youtube_id)
  end
end
