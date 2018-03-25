class LivesController < ApplicationController
  permits :name, :date, :place, :album_url

  before_action :admin_or_elder_user, only: %i[new edit create update destroy]

  def index
    @lives = Live.published.order_by_date
  end

  def show(id)
    @live = Live.includes(:songs).find(id)
    redirect_to live_entries_url(@live) unless @live.published?
  end

  def new
    @live = Live.new.tap { |l| l.date = Time.zone.today }
  end

  def edit(id)
    @live = Live.find(id)
  end

  def create(live)
    @live = Live.new(live)
    if @live.save
      flash[:success] = t(:created, name: @live.title)
      redirect_to @live.published? ? @live : live_entries_url(@live)
    else
      render :new, status: :unprocessable_entity
    end
  end

  def update(id, live)
    @live = Live.find(id)
    if @live.update(live)
      flash[:success] = t(:updated, name: @live.title)
      redirect_to @live
    else
      render :edit, status: :unprocessable_entity
    end
  end

  def destroy(id)
    @live = Live.find(id)
    @live.destroy
  rescue ActiveRecord::DeleteRestrictionError => e
    flash.now[:danger] = e.message
    render :show, status: :unprocessable_entity
  else
    flash[:success] = t(:deleted, name: t(:'activerecord.models.live'))
    redirect_to lives_url
  end
end
