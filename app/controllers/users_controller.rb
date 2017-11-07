class UsersController < ApplicationController
  before_action :set_user, only: %i[edit update destroy]
  before_action :logged_in_user, except: %i[index show search]
  before_action :check_public, only: %i[show search]
  before_action :search_params_validation, only: :search
  before_action :correct_user, only: %i[edit update]
  before_action :admin_or_elder_user, only: %i[new create destroy]

  def index
    @users = if params[:active] != 'false'
               User.active.natural_order
             else
               User.natural_order
             end
  end

  def show
    @songs = @user.songs.published.order_by_live.includes(playings: :user)
  end

  def search
    @search.ids = @user.songs.pluck(:id)
    @songs = Song.search(@search.to_payload).records(includes: { playings: :user })
    render :show
  end

  def new
    @user = User.new
  end

  def create
    @user = User.new(create_user_params)
    if @user.save
      flash[:success] = 'メンバーを追加しました'
      redirect_to action: :new
    else
      render :new
    end
  end

  def edit
    #
  end

  def update
    if @user.update(update_user_params)
      flash[:success] = 'プロフィールを更新しました'
      redirect_to @user
    else
      render :edit
    end
  end

  def destroy
    @user.destroy
  rescue ActiveRecord::DeleteRestrictionError => e
    flash.now[:danger] = e.message
    render :show
  else
    flash[:success] = 'メンバーを削除しました'
    redirect_to users_url
  end

  private

  def create_user_params
    params.require(:user).permit(:first_name, :last_name, :furigana, :joined)
  end

  def update_user_params
    params.require(:user).permit(:first_name, :last_name, :furigana, :nickname, :email, :url, :intro, :public)
  end

  def search_params
    params.permit(:artist, :instruments, :players_lower, :players_upper, :date_lower, :date_upper, :user_id)
  end

  # Before filters

  def set_user
    @user = User.find(params[:id])
  end

  def check_public
    @user = User.includes(songs: :live).find(params[:id])
    redirect_to(root_url) unless logged_in? || @user.public?
  end

  def search_params_validation
    @search = Song::Search.new(search_params)
    render :show, status: :bad_request if @search.invalid?
  end

  def correct_user
    redirect_to(root_url) unless current_user?(@user)
  end
end
