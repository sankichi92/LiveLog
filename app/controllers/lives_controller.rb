class LivesController < ApplicationController
  after_action :verify_authorized, except: %i[index show]

  def index
    @lives = Live.published.newest_order
  end

  def show(id)
    @live = Live.find(id)
    redirect_to live_entries_url(@live) unless @live.published?
    @songs = @live.songs.with_attached_audio.includes(playings: :member).played_order
  end

  def album(id)
    @live = Live.find(id)
    authorize @live
    redirect_to @live.album_url.presence || @live
  end
end
