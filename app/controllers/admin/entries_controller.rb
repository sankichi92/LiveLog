module Admin
  class EntriesController < AdminController
    permits :notes, playable_times_attributes: %i[id lower upper _destroy]

    def index(playable_time = nil)
      entries = Entry.preload(:member, :playable_times, song: [:live, { plays: :member }]).order(id: :desc)
      @entries = if (parsed_playable_time = Time.zone.parse(playable_time.to_s))
                   entries.joins(:playable_times).merge(PlayableTime.contains(parsed_playable_time))
                 else
                   entries
                 end
    end

    def edit(id)
      @entry = Entry.find(id)
    end

    def update(id, entry, song)
      @entry = Entry.find(id)
      @entry.song.assign_attributes(song.permit(:live_id, :time, :position))

      if @entry.update(entry)
        @entry.song.save!
        AdminActivityNotifyJob.perform_later(
          user: current_user,
          operation: '更新しました',
          object: @entry,
          detail: @entry.song.previous_changes.empty? ? @entry.previous_changes : @entry.previous_changes.merge(song: @entry.song.previous_changes),
          url: admin_entries_url,
        )
        redirect_to admin_entries_path, notice: "ID: #{@entry.id} を更新しました"
      else
        render :edit, status: :unprocessable_entity
      end
    end

    def destroy(id)
      entry = Entry.find(id)
      json = entry.as_json(include: [:playable_times, { song: { include: :plays } }])
      entry.song.destroy!
      AdminActivityNotifyJob.perform_now(
        user: current_user,
        operation: '削除しました',
        object: entry,
        detail: json,
        url: admin_entries_url,
      )
      redirect_to admin_entries_path, notice: "ID: #{entry.id} を削除しました"
    end
  end
end
