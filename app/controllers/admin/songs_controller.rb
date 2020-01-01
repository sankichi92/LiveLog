module Admin
  class SongsController < AdminController
    permits :time, :position, :name, :artist, :original, :youtube_url, :audio, playings_attributes: %i[member_id inst _destroy]

    def new(live_id)
      @live = Live.find(live_id)
      @song = @live.songs.build
      @song.playings.build
    end

    def create(live_id, song)
      @live = Live.find(live_id)
      @song = @live.songs.build(song)

      if @song.save_with_playings_attributes
        AdminActivityNotifyJob.perform_later(current_user, "#{Song.model_name.human} #{@song.id} を追加しました")
        redirect_to admin_live_path(@live), notice: "#{@song.title} を追加しました"
      else
        render :new, status: :unprocessable_entity
      end
    end

    def destroy(id)
      song = Song.find(id)
      song.destroy!
      AdminActivityNotifyJob.perform_later(current_user, "#{Song.model_name.human} #{song.id} を削除しました")
      redirect_to admin_live_path(song.live), notice: "ID: #{song.id} を削除しました"
    end
  end
end
