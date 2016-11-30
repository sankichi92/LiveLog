class PasswordsController < ApplicationController
  before_action :logged_in_user
  before_action :correct_user

  def edit
  end

  def update
    if @user.authenticate(params[:user][:current_password])
      if @user.update_attributes(password_params)
        flash[:success] = 'パスワードを変更しました'
        redirect_to @user
      else
        render :edit
      end
    else
      @user.errors.add(:current_password, ' が異なります')
      render :edit
    end
  end

  private

  def password_params
    params.require(:user).permit(:password, :password_confirmation)
  end

  def correct_user
    @user = User.find(params[:user_id])
    redirect_to(root_url) unless current_user?(@user)
  end
end
