class EntriesController < ApplicationController
  before_action :require_current_user
  before_action :require_unpublished_live, only: %i[new create]
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
    @entry.playable_times.build
    @entry.build_song.plays.build
  end

  def create(entry, song)
    @entry = current_user.member.entries.build(entry)
    @entry.build_song(song.permit(:live_id, :name, :artist, :original, :status, :comment, plays_attributes: %i[member_id instrument _destroy]))

    if @entry.save
      EntryActivityNotifyJob.perform_later(
        user: current_user,
        operation: '作成しました',
        entry_id: @entry.id,
        detail: @entry.as_json(include: [:playable_times, { song: { include: :plays } }]),
      )
      EntryMailer.created(@entry).deliver_now
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
      EntryActivityNotifyJob.perform_later(
        user: current_user,
        operation: '更新しました',
        entry_id: @entry.id,
        detail: @entry.song.previous_changes.empty? ? @entry.previous_changes : @entry.previous_changes.merge(song: @entry.song.previous_changes),
      )
      redirect_to entries_path, notice: "エントリー ID: #{@entry.id} を更新しました"
    else
      render :new, status: :unprocessable_entity
    end
  end

  def destroy
    json = @entry.as_json(include: [:playable_times, { song: { include: :plays } }])
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

  def require_unpublished_live
    redirect_back fallback_location: root_path, alert: 'エントリー募集中のライブがありません' unless Live.unpublished.exists?
  end

  def require_submitter_or_player(id)
    @entry = Entry.find(id)
    redirect_back fallback_location: entries_path, alert: '権限がありません' if !@entry.submitter?(current_user) && !@entry.song.player?(current_user.member)
  end

  # endregion
end
