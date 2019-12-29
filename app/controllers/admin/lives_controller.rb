module Admin
  class LivesController < AdminController
    permits :name, :date, :place, :album_url

    def index(year = Live.maximum(:date).nendo)
      @year = year.to_i
      @lives = Live.nendo(@year).newest_order
    end

    def new
      @live = Live.new(date: Time.zone.today)
    end

    def create(live)
      @live = Live.new(live)

      if @live.save
        AdminActivityNotifyJob.perform_later(current_user, "#{Live.model_name.human} #{@live.title} を作成しました")
        redirect_to admin_lives_path(year: @live.date.nendo), notice: "#{@live.title} を作成しました"
      else
        render :new, status: :unprocessable_entity
      end
    end

    def destroy(id)
      live = Live.find(id)
      live.destroy!
      AdminActivityNotifyJob.perform_later(current_user, "#{Live.model_name.human} #{live.title} を削除しました")
      redirect_to admin_lives_path(year: live.date.nendo), notice: "#{live.title} を削除しました"
    end
  end
end
