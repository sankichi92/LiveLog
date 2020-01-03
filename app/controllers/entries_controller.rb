class EntriesController < ApplicationController
  before_action :require_current_user
  before_action :require_unpublished_live, only: %i[new create]

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
    @entry.build_song(song.permit(:live_id, :name, :artist, :original, :status, :comment, plays_attributes: %i[id member_id instrument _destroy]))

    if @entry.save
      redirect_to entries_path, notice: "#{@entry.song.live.title} に #{@entry.song.title} をエントリーしました"
    else
      render :new, status: :unprocessable_entity
    end
  end

  private

  # region Filters

  def require_unpublished_live
    redirect_to entries_path, alert: 'エントリー募集中のライブがありません' unless Live.unpublished.exists?
  end

  # endregion
end
