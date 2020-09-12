class SongsController < ApplicationController
  before_action :require_current_user, only: %i[edit update]
  before_action :require_player, only: %i[edit update]

  permits :name, :artist, :original, :visibility, :comment, plays_attributes: %i[id member_id instrument _destroy]

  def index(page = 1)
    @songs = Song.includes(:live, plays: :member).published.newest_live_order.page(page)
    @query = Song::SearchQuery.new
  end

  def search(page = 1)
    @query = Song::SearchQuery.new(search_params.merge(logged_in: !current_user.nil?))
    if @query.valid?
      @songs = Song.search(@query).page(page).records(includes: [:live, { plays: :member }])
      render :index
    else
      render :index, status: :unprocessable_entity
    end
  end

  def show(id)
    @song = Song.published.includes(plays: { member: %i[avatar user] }).find(id)
    begin
      @related_songs = @song.more_like_this.records(includes: [:live, { plays: :member }]).to_a
    rescue => e
      Raven.capture_exception(e)
    end
  end

  def edit
  end

  def update(song)
    if @song.update(song)
      redirect_to song_path(@song), notice: '更新しました'
    else
      render :edit, status: :unprocessable_entity
    end
  end

  private

  # region Filters

  def require_player(id)
    @song = Song.published.find(id)
    redirect_back fallback_location: song_path(@song), alert: '権限がありません' unless @song.player?(current_user.member)
  end

  # endregion

  # region Strong parameters

  def search_params
    params.permit(:q, :name, :artist, :instruments, :players_lower, :players_upper, :date_lower, :date_upper, :media, :original)
  end

  # endregion
end
