class LivesController < ApplicationController
  permits :name, :date, :place, :album_url

  after_action :verify_authorized, except: %i[index show]

  def index
    @lives = Live.published.order_by_date
  end

  def show(id)
    @live = Live.find(id)
    redirect_to live_entries_url(@live) unless @live.published?
    @songs = @live.songs.with_attached_audio.includes(playings: :member).played_order
  end

  def album(id)
    @live = Live.find(id)
    authorize @live
    redirect_to @live.album_url.presence || @live
  end

  def new
    @live = Live.new.tap { |l| l.date = Time.zone.today }
    authorize @live
  end

  def create(live)
    @live = Live.new(live)
    authorize @live
    if @live.save
      redirect_to @live.published? ? @live : live_entries_url(@live), notice: "#{@live.title} を追加しました"
    else
      render :new, status: :unprocessable_entity
    end
  end

  def edit(id)
    @live = Live.find(id)
    authorize @live
  end

  def update(id, live)
    @live = Live.find(id)
    authorize @live
    if @live.update(live)
      redirect_to @live, notice: "#{@live.title} を更新しました"
    else
      render :edit, status: :unprocessable_entity
    end
  end

  def publish(id)
    @live = Live.find(id)
    if @live.published?
      skip_authorization
    else
      authorize @live
      @live.publish(live_url(@live))
      flash.notice = '公開しました'
    end
    redirect_to @live, status: :moved_permanently
  end

  def destroy(id)
    @live = Live.find(id)
    authorize @live
    @live.destroy
  rescue ActiveRecord::DeleteRestrictionError => e
    redirect_to @live, alert: e.message
  else
    redirect_to lives_url, notice: "#{@live.title} を削除しました"
  end
end
