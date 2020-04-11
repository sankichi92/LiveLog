class EntriesController < ApplicationController
  before_action :require_current_user
  before_action :require_entry_acceptable_live, only: %i[new create]
  before_action :require_submitter_or_player, only: %i[edit update destroy]

  permits :notes, playable_times_attributes: %i[id lower upper _destroy]

  def index
    @entries = Entry
                 .includes(:playable_times, song: [:live, { plays: :member }])
                 .submitted_or_played_by(current_user.member)
                 .order(id: :desc)
    redirect_to new_entry_path unless @entries.exists?
  end

  def new
    @entry = current_user.member.entries.build
    live = Live.entry_acceptable.order(:date).first
    @entry.playable_times.build(range: live.time_range)
    @entry.build_song(live: live).plays.build
  end

  def create(entry, song)
    @entry = current_user.member.entries.build(entry)
    @entry.build_song(song.permit(:live_id, :name, :artist, :original, :visibility, :comment, plays_attributes: %i[member_id instrument _destroy]))

    @entry.save!
    EntryActivityNotifyJob.perform_later(
      user: current_user,
      operation: '作成しました',
      entry_id: @entry.id,
      detail: @entry.as_json_for_notification,
    )
    redirect_to entries_path, notice: "エントリー ID: #{@entry.id} を作成しました"
  rescue ActiveRecord::RecordInvalid => e
    Raven.capture_exception(e, level: :debug)
    render :new, status: :unprocessable_entity
  end

  def edit
  end

  def update(entry, song)
    @entry.song.assign_attributes(
      song.permit(:live_id, :name, :artist, :original, :visibility, :comment, plays_attributes: %i[id member_id instrument _destroy]),
    )

    @entry.transaction do
      @entry.update!(entry)
      @entry.song.save!
    end
    EntryActivityNotifyJob.perform_later(
      user: current_user,
      operation: '更新しました',
      entry_id: @entry.id,
      detail: @entry.song.previous_changes.empty? ? @entry.previous_changes : @entry.previous_changes.merge(song: @entry.song.previous_changes),
    )
    redirect_to entries_path, notice: "エントリー ID: #{@entry.id} を更新しました"
  rescue ActiveRecord::RecordInvalid => e
    Raven.capture_exception(e, level: :debug)
    render :edit, status: :unprocessable_entity
  end

  def destroy
    json = @entry.as_json_for_notification
    @entry.song.destroy!
    EntryActivityNotifyJob.perform_later(
      user: current_user,
      operation: '削除しました',
      entry_id: @entry.id,
      detail: json,
    )
    redirect_to entries_path, notice: "エントリー ID: #{@entry.id} を削除しました"
  end

  private

  # region Filters

  def require_entry_acceptable_live
    redirect_back fallback_location: root_path, alert: 'エントリー募集中のライブがありません' unless Live.entry_acceptable.exists?
  end

  def require_submitter_or_player(id)
    @entry = Entry.find(id)
    redirect_back fallback_location: entries_path, alert: '権限がありません' if !@entry.submitter?(current_user) && !@entry.song.player?(current_user.member)
  end

  # endregion
end
