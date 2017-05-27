class LivesController < ApplicationController
  before_action :set_live, only: %i[edit update destroy]
  before_action :logged_in_user, except: %i[index show]
  before_action :admin_or_elder_user, except: %i[index show]

  def index
    @lives = Live.order_by_date
  end

  def show
    @live = Live.includes(songs: %i[playings users]).find(params[:id])
  end

  def new
    @live = Live.new
  end

  def edit
    #
  end

  def create
    @live = Live.new(live_params)

    respond_to do |format|
      if @live.save
        format.html do
          flash[:success] = "#{@live.title} を追加しました"
          redirect_to @live
        end
        format.json { render :show, status: :created, location: @live }
      else
        format.html { render :new }
        format.json { render json: @live.errors, status: :unprocessable_entity }
      end
    end
  end

  def update
    respond_to do |format|
      if @live.update(live_params)
        format.html do
          flash[:success] = "#{@live.title} を更新しました"
          redirect_to @live
        end
        format.json { render :show, status: :ok, location: @live }
      else
        format.html { render :edit }
        format.json { render json: @live.errors, status: :unprocessable_entity }
      end
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

  # Use callbacks to share common setup or constraints between actions.
  def set_live
    @live = Live.find(params[:id])
  end

  # Never trust parameters from the scary internet, only allow the white list through.
  def live_params
    params.require(:live).permit(:name, :date, :place)
  end
end
