class SongsController < ApplicationController
  permits :live_id, :time, :order, :name, :artist, :youtube_id, :status, :comment, :original, playings_attributes: %i[id user_id inst _destroy]

  after_action :verify_authorized

  before_action :store_referer, only: :edit

  def index(page = 1)
    skip_authorization
    @songs = Song.published.order_by_live.includes(playings: :user).page(page)
    @query = Song::SearchQuery.new
  end

  def search(page = 1)
    skip_authorization
    @query = Song::SearchQuery.new(search_params.merge(logged_in: logged_in?))
    if @query.valid?
      @songs = Song.search(@query).page(page).records(includes: [:live, { playings: :user }])
      render :index
    else
      render :index, status: :unprocessable_entity
    end
  end

  def show(id)
    skip_authorization
    @song = Song.published.includes(playings: :user).find(id)
  end

  def watch(id)
    if request.xhr?
      @song = Song.published.includes(playings: :user).find(id)
      authorize @song
    else
      skip_authorization
      redirect_to song_path(id)
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
      flash[:success] = t(:created, name: @song.title)
      redirect_to @song.live
    else
      render :new, status: :unprocessable_entity
    end
  rescue ActiveRecord::RecordNotUnique
    @song.add_error_for_duplicated_user
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
      flash[:success] = t(:updated, name: @song.title)
      redirect_back_or @song
    else
      render :edit, status: :unprocessable_entity
    end
  rescue ActiveRecord::RecordNotUnique
    @song.add_error_for_duplicated_user
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
    flash[:success] = t(:deleted, name: t(:'activerecord.models.song'))
    redirect_to @song.live
  end

  private

  def search_params
    params.permit(:q, :name, :artist, :instruments, :players_lower, :players_upper, :date_lower, :date_upper, :video, :original)
  end
end
