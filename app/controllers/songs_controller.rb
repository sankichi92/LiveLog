class SongsController < ApplicationController
  before_action :set_song, only: %i[show edit update destroy]
  before_action :logged_in_user, except: %i[index show]
  before_action :correct_user, only: %i[edit update]
  before_action :correct_user, only: :show, if: :future_song?
  before_action :admin_or_elder_user, only: %i[new create destroy]
  before_action :store_referer, only: :edit

  def index
    @songs = Song.past.includes(playings: :user).search(params[:q], params[:page])
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

  def correct_user
    redirect_to(root_url) unless current_user.played?(@song) || current_user.admin_or_elder?
  end

  def set_song
    @song = Song.includes(playings: :user).find(params[:id])
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

  def store_referer
    session[:forwarding_url] = request.referer || root_url
  end

  def future_song?
    @song.live.future?
  end
end
