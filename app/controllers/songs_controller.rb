# frozen_string_literal: true

class SongsController < ApplicationController
  before_action :require_current_user, only: %i[edit update]
  before_action :require_player, only: %i[edit update]

  permits :name, :artist, :original, :visibility, :comment, plays_attributes: %i[id member_id instrument _destroy]

  def index(page = 1)
    @songs = Song.includes(:live, plays: :member).published.newest_live_order.page(page)
    @song_search_form = SongSearchForm.new
  end

  def search(page = 1)
    @song_search_form = SongSearchForm.new(search_params)
    return render :index, status: :unprocessable_entity if params[:q].nil? && @song_search_form.invalid?

    query = if params[:q].present?
              Song.basic_search_query(params[:q])
            else
              Song.advanced_search_query(logged_in: !current_user.nil?, **@song_search_form.to_h)
            end

    @songs = Song.search(query).page(page).records(includes: [:live, { plays: :member }])
    render :index
  end

  def show(id)
    @song = Song.published.includes(plays: { member: %i[avatar user] }).find(id)
    @related_songs = begin
                       Song.search(@song.more_like_this_query).records(includes: [:live, { plays: :member }]).to_a
                     rescue => e
                       Raven.capture_exception(e)
                       []
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
    params.permit(:name, :artist, :instruments, :players_lower, :players_upper, :date_lower, :date_upper, :has_media, :original)
  end

  # endregion
end
