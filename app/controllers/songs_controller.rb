class SongsController < ApplicationController
  permits :live_id, :time, :order, :name, :artist, :youtube_id, :status, :comment, :original, playings_attributes: %i[id user_id inst _destroy]

  before_action :admin_or_elder_user, only: %i[new create destroy]
  before_action :editable_user, only: %i[edit update]
  before_action :store_referer, only: :edit

  def index(page = 1)
    @songs = Song.published.includes(playings: :user).page(page).order_by_live
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

  def watch(id)
    return redirect_to song_path(id) unless request.xhr?
    @song = Song.published.includes(playings: :user).find(id)
    render plain: '', status: :forbidden unless @song.watchable?(current_user)
  end

  def new(live_id = nil)
    live = Live.find_by(id: live_id) || Live.last
    @song = live.songs.build
    @song.playings.build
  end

  def create(song)
    @song = Song.new(song)
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

  def edit; end

  def update(song)
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
    live = @song.live
    @song.destroy
  rescue ActiveRecord::DeleteRestrictionError => e
    flash.now[:danger] = e.message
    render :show
  else
    flash[:success] = t(:deleted, name: t(:'activerecord.models.song'))
    redirect_to live
  end

  private

  def editable_user(id)
    @song = Song.includes(playings: :user).find(id)
    raise User::NotAuthorized unless @song.editable?(current_user)
  end

  def search_params
    params.permit(:q, :name, :artist, :instruments, :players_lower, :players_upper, :date_lower, :date_upper, :video, :original)
  end
end
