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

    def edit(id)
      @live = Live.find(id)
    end

    def update(id, live)
      @live = Live.find(id)

      if @live.update(live)
        AdminActivityNotifyJob.perform_later(current_user, "#{Live.model_name.human} #{@live.title} を更新しました")
        redirect_to admin_lives_path(year: @live.date.nendo), notice: "#{@live.title} を更新しました"
      else
        render :edit, status: :unprocessable_entity
      end
    end

    def destroy(id)
      live = Live.find(id)
      live.destroy!
      AdminActivityNotifyJob.perform_later(current_user, "#{Live.model_name.human} #{live.title} を削除しました")
      redirect_to admin_lives_path(year: live.date.nendo), notice: "#{live.title} を削除しました"
    end

    def publish(id)
      live = Live.find(id)
      live.publish!
      TweetJob.perform_later("#{live.title} のセットリストが公開されました！\n#{live_url(live)}")
      AdminActivityNotifyJob.perform_later(current_user, "#{Live.model_name.human} #{live.title} を公開しました")
      redirect_to admin_lives_path(year: live.date.nendo), notice: "#{live.title} を公開しました"
    end
  end
end
