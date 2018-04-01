class LivesController < ApplicationController
  permits :name, :date, :place, :album_url

  after_action :verify_authorized, except: %i[index show]

  def index
    @lives = Live.published.order_by_date
  end

  def show(id)
    @live = Live.includes(:songs).find(id)
    redirect_to live_entries_url(@live) unless @live.published?
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
      flash[:success] = t(:created, name: @live.title)
      redirect_to @live.published? ? @live : live_entries_url(@live)
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
      flash[:success] = t(:updated, name: @live.title)
      redirect_to @live
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
      flash[:success] = t(:published)
    end
    redirect_to @live, status: :moved_permanently
  end

  def destroy(id)
    @live = Live.find(id)
    authorize @live
    @live.destroy
  rescue ActiveRecord::DeleteRestrictionError => e
    flash.now[:danger] = e.message
    render :show, status: :unprocessable_entity
  else
    flash[:success] = t(:deleted, name: @live.title)
    redirect_to lives_url
  end
end
