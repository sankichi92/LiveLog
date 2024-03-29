# frozen_string_literal: true

module Admin
  class SongsController < AdminController
    before_action -> { require_scope('write:songs') }

    permits :live_id, :time, :position, :name, :artist, :original, :youtube_url, :audio, plays_attributes: %i[id member_id instrument _destroy]

    def new(live_id)
      @live = Live.find(live_id)
      @song = @live.songs.build
      @song.plays.build
    end

    def edit(id)
      @song = Song.find(id)
    end

    def create(live_id, song)
      @live = Live.find(live_id)
      @song = @live.songs.build(song)

      if @song.save
        AdminActivityNotifyJob.perform_later(
          user: current_user,
          operation: '作成しました',
          object: @song,
          detail: @song.as_json(include: :plays),
          url: admin_live_url(@live),
        )
        redirect_to admin_live_path(@live), notice: "ID: #{@song.id} を追加しました"
      else
        render :new, status: :unprocessable_entity
      end
    end

    def update(id, song)
      @song = Song.find(id)
      @song.assign_attributes(song)

      if @song.save
        AdminActivityNotifyJob.perform_later(
          user: current_user,
          operation: '更新しました',
          object: @song,
          detail: @song.previous_changes,
          url: admin_live_url(@song.live),
        )
        redirect_to admin_live_path(@song.live), notice: "ID: #{@song.id} を更新しました"
      else
        render :edit, status: :unprocessable_entity
      end
    end

    def destroy(id)
      song = Song.find(id)
      json = song.as_json(include: :plays)
      song.destroy!
      AdminActivityNotifyJob.perform_now(
        user: current_user,
        operation: '削除しました',
        object: song,
        detail: json,
        url: admin_live_url(song.live),
      )
      redirect_to admin_live_path(song.live), notice: "ID: #{song.id} を削除しました"
    end
  end
end
