class SongsController < ApplicationController
  before_action :set_song, only: %i[show edit update destroy]
  before_action :logged_in_user, only: %i[new create edit update destroy]
  before_action :correct_user, only: %i[edit update]
  before_action :correct_user_for_draft_song, only: :show, if: :draft_song?
  before_action :admin_or_elder_user, only: %i[new create destroy]
  before_action :store_referer, only: :edit
  before_action :search_params_validation, only: :search

  def index
    @songs = Song.published.includes(playings: :user).page(params[:page]).order_by_live
  end

  def search
    response = Song.search(@query).page(params[:page])
    @songs = response.records(includes: [:live, { playings: :user }])
    render :index
  end

  def show
    #
  end

  def new
    live = Live.find_by(id: params[:live_id]) || Live.last
    @song = live.songs.build
    @song.playings.build
  end

  def create
    @song = Song.new(song_params)
    if @song.save
      flash[:success] = '曲を追加しました'
      redirect_to @song.live
    else
      render :new
    end
  rescue ActiveRecord::RecordNotUnique
    @song.add_error_for_duplicated_user
    render :new
  end

  def edit
    #
  end

  def update
    respond_to do |format|
      if @song.update_attributes(song_params)
        format.html do
          flash[:success] = '曲を更新しました'
          redirect_back_or @song
        end
        format.js { flash.now[:success] = '更新しました' }
      else
        format.html { render :edit }
        format.js { flash.now[:danger] = @song.errors.full_messages }
      end
    end
  rescue ActiveRecord::RecordNotUnique
    @song.add_error_for_duplicated_user
    render :edit
  end

  def destroy
    live = @song.live
    @song.destroy
  rescue ActiveRecord::DeleteRestrictionError => e
    flash.now[:danger] = e.message
    render :show
  else
    flash[:success] = '曲を削除しました'
    redirect_back_or live
  end

  private

  def set_song
    @song = Song.includes(playings: :user).find(params[:id])
  end

  def correct_user
    redirect_to(root_url) unless current_user.played?(@song) || current_user.admin_or_elder?
  end

  def correct_user_for_draft_song
    correct_user
  end

  def store_referer
    session[:forwarding_url] = request.referer || root_url
  end

  def draft_song?
    !@song.published?
  end

  def search_params_validation
    @query = Song::SearchQuery.new(search_params.merge(logged_in: logged_in?))
    render :index, status: :bad_request if @query.invalid?
  end

  def song_params
    params.require(:song).permit(:live_id,
                                 :time,
                                 :order,
                                 :name,
                                 :artist,
                                 :youtube_id,
                                 :status,
                                 :comment,
                                 playings_attributes: %i[id user_id inst _destroy])
  end

  def search_params
    params.permit(:q, :name, :artist, :instruments, :players_lower, :players_upper, :date_lower, :date_upper, :video)
  end
end
