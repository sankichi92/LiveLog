class EntriesController < ApplicationController
  before_action :require_current_user
  before_action :require_unpublished_live, only: %i[new create]
  before_action :require_submitter_or_player, only: %i[edit update]

  permits :notes, available_times_attributes: %i[id lower upper _destroy]

  def index
    @entries = Entry
                 .includes(:available_times, song: [:live, { plays: :member }])
                 .submitted_or_played_by(current_user.member)
                 .order(id: :desc)
  end

  def new
    @entry = current_user.member.entries.build
    @entry.available_times.build
    @entry.build_song.plays.build
  end

  def create(entry, song)
    @entry = current_user.member.entries.build(entry)
    @entry.build_song(song.permit(:live_id, :name, :artist, :original, :status, :comment, plays_attributes: %i[member_id instrument _destroy]))

    if @entry.save
      redirect_to entries_path, notice: "エントリー ID: #{@entry.id} を作成しました"
    else
      render :new, status: :unprocessable_entity
    end
  end

  def edit
  end

  def update(entry, song)
    @entry.song.assign_attributes(song.permit(:live_id, :name, :artist, :original, :status, :comment, plays_attributes: %i[id member_id instrument _destroy]))

    if @entry.update(entry)
      @entry.song.save!
      redirect_to entries_path, notice: "エントリー ID: #{@entry.id} を更新しました"
    else
      render :new, status: :unprocessable_entity
    end
  end

  private

  # region Filters

  def require_unpublished_live
    redirect_to entries_path, alert: 'エントリー募集中のライブがありません' unless Live.unpublished.exists?
  end

  def require_submitter_or_player(id)
    @entry = Entry.find(id)
    redirect_back fallback_location: entries_path, alert: '権限がありません' if !@entry.submitter?(current_user) && !@entry.song.player?(current_user.member)
  end

  # endregion
end
