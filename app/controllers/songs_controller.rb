class SongsController < ApplicationController
  permits :live_id, :time, :order, :name, :artist, :original, :youtube_id, :audio, :status, :comment, playings_attributes: %i[id user_id inst _destroy]

  after_action :verify_authorized, except: %i[index search show]

  def index(page = 1)
    @songs = Song.published.order_by_live.includes(playings: :user).page(page)
    @query = Song::SearchQuery.new
  end

  def search(page = 1)
    @query = Song::SearchQuery.new(search_params.merge(logged_in: logged_in?))
    if @query.valid?
      @songs = Song.search(@query).page(page).records(includes: [:live, { playings: :user }])
      render :index
    else
      render :index, status: :unprocessable_entity
    end
  end

  def show(id)
    @song = Song.includes(playings: { user: { 'avatar_attachment': :blob } }).find(id)
    begin
      @related_songs = @song.more_like_this.records(includes: [:live, { playings: :user }]).to_a if @song.live.published?
    rescue => e
      Raven.capture_exception(e)
    end
  end

  def new(live_id = nil)
    live = Live.find_by(id: live_id) || Live.last
    @song = live.songs.build
    @song.playings.build
    authorize @song
  end

  def create(song)
    @song = Song.new(song)
    authorize @song
    if @song.save
      flash[:success] = "#{@song.title} を追加しました"
      redirect_to @song.live
    else
      render :new, status: :unprocessable_entity
    end
  rescue ActiveRecord::RecordNotUnique
    @song.errors.add(:playings, :duplicated)
    render :new, status: :unprocessable_entity
  end

  def edit(id)
    @song = Song.includes(playings: :user).find(id)
    authorize @song
  end

  def update(id, song)
    @song = Song.find(id)
    authorize @song
    if @song.update(song)
      respond_to do |format|
        format.html do
          flash[:success] = "#{@song.title} を更新しました"
          redirect_to @song
        end
        format.js {}
      end
    else
      respond_to do |format|
        format.html { render :edit, status: :unprocessable_entity }
        format.js { render status: :unprocessable_entity }
      end
    end
  rescue ActiveRecord::RecordNotUnique
    @song.errors.add(:playings, :duplicated)
    render :edit, status: :unprocessable_entity
  end

  def destroy(id)
    @song = Song.find(id)
    authorize @song
    @song.destroy
  rescue ActiveRecord::DeleteRestrictionError => e
    flash.now[:danger] = e.message
    render :show
  else
    flash[:success] = "#{@song.title} を削除しました"
    redirect_to @song.live
  end

  private

  def search_params
    params.permit(:q, :name, :artist, :instruments, :players_lower, :players_upper, :date_lower, :date_upper, :media, :original)
  end
end
