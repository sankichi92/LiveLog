class SongsController < ApplicationController
  permits :time, :position, :name, :artist, :original, :audio, :status, :comment, plays_attributes: %i[id member_id inst _destroy]

  after_action :verify_authorized, except: %i[index search show]

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
    @song = Song.includes(plays: { member: { 'avatar_attachment': :blob } }).find(id)
    begin
      @related_songs = @song.more_like_this.records(includes: [:live, { plays: :member }]).to_a if @song.live.published?
    rescue => e
      Raven.capture_exception(e)
    end
  end

  def edit(id)
    @song = Song.includes(plays: :member).find(id)
    authorize @song
  end

  def update(id, song)
    @song = Song.find(id)
    authorize @song
    if @song.update(song)
      redirect_to @song, notice: "#{@song.title} を更新しました"
    else
      render :edit, status: :unprocessable_entity
    end
  rescue ActiveRecord::RecordNotUnique
    @song.errors.add(:plays, :duplicated)
    render :edit, status: :unprocessable_entity
  end

  private

  def search_params
    params.permit(:q, :name, :artist, :instruments, :players_lower, :players_upper, :date_lower, :date_upper, :media, :original)
  end
end
