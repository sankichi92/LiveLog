class EntriesController < ApplicationController
  before_action :set_live
  before_action :logged_in_user

  def new
    @song = @live.songs.build
    @song.playings.build
  end

  def create
  end

  private

  def set_live
    @live = Live.find(params[:live_id])
  end
end
