class UsersController < ApplicationController
  before_action :set_user, only: %i[show edit update destroy]
  before_action :logged_in_user, except: %i[index show]
  before_action :check_public, only: :show
  before_action :correct_user, only: %i[edit update]
  before_action :admin_or_elder_user, only: %i[new create destroy]

  def index
    @users = User.natural_order

    unless logged_in?
      @users = @users.where(public: true)
      return
    end

    return unless params[:active] == 'true'

    today  = Date.today
    range  = (today - 1.year..today)
    @users = @users.includes(songs: :live).where('lives.date' => range)
  end

  def show
    @playings = Playing.where(song_id: @user.songs.pluck('songs.id'))
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
    if @user.update_attributes(update_user_params)
      flash[:success] = 'プロフィールを更新しました'
      redirect_to @user
    else
      render :edit
    end
  end

  def destroy
    @user.destroy
    flash[:success] = 'メンバーを削除しました'
    redirect_to users_url
  end

  private

  def create_user_params
    params.require(:user).permit(:first_name, :last_name, :furigana, :joined)
  end

  def update_user_params
    params.require(:user).permit(
      :first_name, :last_name, :furigana, :nickname,
      :email, :url, :intro, :public
    )
  end

  # Before filters

  def set_user
    @user = User.find(params[:id])
  end

  def check_public
    redirect_to(root_url) unless logged_in? || @user.public?
  end

  def correct_user
    redirect_to(root_url) unless current_user?(@user)
  end
end
