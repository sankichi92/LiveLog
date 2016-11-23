class LivesController < ApplicationController
  before_action :set_live, only: %i(show edit update destroy)
  before_action :logged_in_user, except: %i(index show)
  before_action :admin_or_elder_user, except: %i(index show)

  def index
    @lives = Live.order(date: :desc)
  end

  def show
  end

  # GET /lives/new
  def new
    @live = Live.new
  end

  # GET /lives/1/edit
  def edit
  end

  # POST /lives
  # POST /lives.json
  def create
    @live = Live.new(live_params)

    respond_to do |format|
      if @live.save
        format.html { redirect_to @live, notice: 'Live was successfully created.' }
        format.json { render :show, status: :created, location: @live }
      else
        format.html { render :new }
        format.json { render json: @live.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /lives/1
  # PATCH/PUT /lives/1.json
  def update
    respond_to do |format|
      if @live.update(live_params)
        format.html { redirect_to @live, notice: 'Live was successfully updated.' }
        format.json { render :show, status: :ok, location: @live }
      else
        format.html { render :edit }
        format.json { render json: @live.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /lives/1
  # DELETE /lives/1.json
  def destroy
    @live.destroy
    respond_to do |format|
      format.html { redirect_to lives_url, notice: 'Live was successfully destroyed.' }
      format.json { head :no_content }
    end
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
