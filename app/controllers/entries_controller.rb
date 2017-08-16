class EntriesController < ApplicationController
  before_action :logged_in_user
  before_action :set_live
  before_action :future_live

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

  def future_live
    redirect_to root_url if @live.date <= Date.today
  end
end
