class SongsController < ApplicationController
  before_action :admin_or_elder_user, only: %i[new create destroy]
  before_action :editable_user, only: %i[edit update]
  before_action :store_referer, only: :edit

  def index
    @songs = Song.published.includes(playings: :user).page(params[:page]).order_by_live
    @query = Song::SearchQuery.new
  end

  def search
    @query = Song::SearchQuery.new(search_params.merge(logged_in: logged_in?))
    if @query.valid?
      @songs = Song.search(@query).page(params[:page]).records(includes: [:live, { playings: :user }])
      render :index
    else
      render :index, status: :unprocessable_entity
    end
  end

  def show
    @song = Song.published.includes(playings: :user).find(params[:id])
  end

  def watch
    return redirect_to song_path(params[:id]) unless request.xhr?
    @song = Song.published.includes(playings: :user).find(params[:id])
    render plain: '', status: :forbidden unless @song.watchable?(current_user)
  end

  def new
    live = Live.find_by(id: params[:live_id]) || Live.last
    @song = live.songs.build
    @song.playings.build
  end

  def create
    @song = Song.new(song_params)
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

  def update
    if @song.update_attributes(song_params)
      flash[:success] = t(:updated, name: @song.title)
      redirect_back_or @song
    else
      render :edit, status: :unprocessable_entity
    end
  rescue ActiveRecord::RecordNotUnique
    @song.add_error_for_duplicated_user
    render :edit, status: :unprocessable_entity
  end

  def destroy
    @song = Song.find(params[:id])
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

  # region Before filters

  def editable_user
    @song = Song.includes(playings: :user).find(params[:id])
    raise User::NotAuthorized unless @song.editable?(current_user)
  end

  # endregion

  # region Strong parameters

  def song_params
    params.require(:song).permit(:live_id,
                                 :time,
                                 :order,
                                 :name,
                                 :artist,
                                 :youtube_id,
                                 :status,
                                 :comment,
                                 :original,
                                 playings_attributes: %i[id user_id inst _destroy])
  end

  def search_params
    params.permit(:q, :name, :artist, :instruments, :players_lower, :players_upper, :date_lower, :date_upper, :video,
                  :original)
  end

  # endregion
end
