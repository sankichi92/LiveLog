# frozen_string_literal: true

module Admin
  class EntryGuidelinesController < AdminController
    before_action -> { require_scope('write:lives') }

    permits :deadline, :notes

    def new(live_id)
      live = Live.unpublished.where.missing(:entry_guideline).find(live_id)
      @entry_guideline = live.build_entry_guideline(deadline: live.date.in_time_zone)
    end

    def edit(live_id)
      @entry_guideline = EntryGuideline.find_by!(live_id:)
    end

    def create(live_id, entry_guideline)
      live = Live.unpublished.where.missing(:entry_guideline).find(live_id)
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

    def update(live_id, entry_guideline)
      @entry_guideline = EntryGuideline.find_by!(live_id:)

      if @entry_guideline.update(entry_guideline)
        AdminActivityNotifyJob.perform_later(
          user: current_user,
          operation: '更新しました',
          object: @entry_guideline,
          detail: @entry_guideline.previous_changes,
          url: admin_lives_url(year: @entry_guideline.live.date.nendo),
        )
        redirect_to admin_lives_path(year: @entry_guideline.live.date.nendo), notice: "#{@entry_guideline.live.name} のエントリー要項を更新しました"
      else
        render :edit, status: :unprocessable_entity
      end
    end
  end
end
