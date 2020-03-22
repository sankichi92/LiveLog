module Admin
  class EntryGuidelinesController < AdminController
    permits :deadline, :notes

    def new(live_id)
      live = Live.unpublished.left_joins(:entry_guideline).where(entry_guidelines: { id: nil }).find(live_id)
      @entry_guideline = live.build_entry_guideline(deadline: live.date.in_time_zone)
    end

    def create(live_id, entry_guideline)
      live = Live.unpublished.left_joins(:entry_guideline).where(entry_guidelines: { id: nil }).find(live_id)
      @entry_guideline = live.build_entry_guideline(entry_guideline)

      if @entry_guideline.save
        AdminActivityNotifyJob.perform_later(
          user: current_user,
          operation: '作成しました',
          object: @entry_guideline,
          detail: @entry_guideline.as_json,
          url: admin_lives_url(year: live.date.nendo),
        )
        redirect_to admin_lives_path(year: live.date.nendo), notice: "#{live.name} のエントリー募集を開始しました"
      else
        render :new, status: :unprocessable_entity
      end
    end

    def edit(live_id)
      live = Live.unpublished.joins(:entry_guideline).find(live_id)
      @entry_guideline = live.entry_guideline
    end

    def update(live_id, entry_guideline)
      live = Live.unpublished.joins(:entry_guideline).find(live_id)
      @entry_guideline = live.entry_guideline

      if @entry_guideline.update(entry_guideline)
        AdminActivityNotifyJob.perform_later(
          user: current_user,
          operation: '更新しました',
          object: @entry_guideline,
          detail: @entry_guideline.previous_changes,
          url: admin_lives_url(year: live.date.nendo),
        )
        redirect_to admin_lives_path(year: live.date.nendo), notice: "#{live.name} のエントリー募集要項を更新しました"
      else
        render :edit, status: :unprocessable_entity
      end
    end
  end
end
