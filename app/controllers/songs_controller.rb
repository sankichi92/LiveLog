class SongsController < ApplicationController
  permits :live_id, :time, :order, :name, :artist, :youtube_id, :status, :comment, :original, playings_attributes: %i[id user_id inst _destroy]

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
    @song = Song.published.includes(playings: :user).find(id)
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
      flash[:success] = t('flash.messages.created', name: @song.title)
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
    store_referer
  end

  def update(id, song)
    @song = Song.find(id)
    authorize @song
    if @song.update(song)
      flash[:success] = t('flash.messages.updated', name: @song.title)
      redirect_back_or @song
    else
      render :edit, status: :unprocessable_entity
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
    flash[:success] = t('flash.messages.deleted', name: @song.title)
    redirect_to @song.live
  end

  private

  def search_params
    params.permit(:q, :name, :artist, :instruments, :players_lower, :players_upper, :date_lower, :date_upper, :video, :original)
  end
end
