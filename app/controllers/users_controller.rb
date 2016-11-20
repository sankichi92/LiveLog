class UsersController < ApplicationController

  def show
    @user = User.find(params[:id])
  end

  def new
    @user = User.new
  end

  def create
    params[:user][:password] = params[:user][:password_confirmation] = 'dummy_pass'
    @user = User.new(user_params)
    if @user.save
      flash[:success] = "#{@user.full_name} さんを追加しました"
      redirect_to @user
    else
      render 'new'
    end
  end

  def signup

  end

  private

  def user_params
    params.require(:user).permit(:first_name, :last_name, :furigana, :nickname, :email, :joined,
                                 :password, :password_confirmation)
  end
end
