class LivesController < ApplicationController
  before_action :set_live, only: %i[show edit update destroy]
  before_action :logged_in_user, except: %i[index show]
  before_action :admin_or_elder_user, except: %i[index show]
  before_action :published_live, only: :show

  def index
    @lives = Live.published.order_by_date
  end

  def show
    #
  end

  def new
    @live = Live.new
    @live.date = Time.zone.today
  end

  def edit
    #
  end

  def create
    @live = Live.new(live_params)
    if @live.save
      flash[:success] = "#{@live.title} を追加しました"
      redirect_to @live
    else
      render :new
    end
  end

  def update
    if @live.update(live_params)
      flash[:success] = "#{@live.title} を更新しました"
      redirect_to @live
    else
      render :edit
    end
  end

  def destroy
    @live.destroy
  rescue ActiveRecord::DeleteRestrictionError => e
    flash.now[:danger] = e.message
    render :show
  else
    flash[:success] = 'ライブを削除しました'
    redirect_to lives_url
  end

  private

  def set_live
    @live = Live.includes(:songs).find(params[:id])
  end

  def published_live
    redirect_to live_entries_url(@live) unless @live.published?
  end

  def live_params
    params.require(:live).permit(:name, :date, :place, :album_url)
  end
end
