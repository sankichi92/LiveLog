class UsersController < ApplicationController
  before_action :logged_in_user
  before_action :correct_user, only: [:edit, :update]
  before_action :admin_user, only: :destroy

  def index
    @users = User.order('furigana COLLATE "C"') # TODO: Remove 'COLLATE "C"'
    @years = User.select(:joined).distinct.order(joined: :desc).map { |u| u.joined }
  end

  def show
    @user = User.find(params[:id])
  end

  def new
    @user = User.new
  end

  def create
    params[:user][:password] = params[:user][:password_confirmation] = 'dummy_password'
    @user = User.new(user_params)
    if @user.save
      flash[:success] = "#{@user.full_name} さんを追加しました"
      redirect_to action: :new
    else
      render 'new'
    end
  end

  def edit
  end

  def update
    if @user.update_attributes(user_params)
      flash[:success] = 'プロフィールを更新しました'
      redirect_to @user
    else
      render 'edit'
    end
  end

  def destroy
    User.find(params[:id]).destroy
    flash[:success] = 'メンバーを削除しました'
    redirect_to users_url
  end

  def invite
    @user = User.find(params[:id])
  end

  private

  def user_params
    params.require(:user).permit(:first_name, :last_name, :furigana, :nickname, :email, :joined,
                                 :password, :password_confirmation)
  end

  # Before filters

  def logged_in_user
    unless logged_in?
      store_location
      flash[:danger] = 'ログインしてください'
      redirect_to login_url
    end
  end

  def correct_user
    @user = User.find(params[:id])
    redirect_to(root_url) unless current_user?(@user)
  end

  def admin_user
    redirect_to(root_url) unless current_user.admin?
  end
end
