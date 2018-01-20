class AdminsController < ApplicationController
  before_action :admin_user
  before_action :set_user

  def create
    @user.update_attribute(:admin, true)
    flash[:success] = '管理者にしました'
    redirect_to @user
  end

  def destroy
    @user.update_attribute(:admin, false)
    flash[:success] = '管理者権限を無効にしました'
    redirect_to @user
  end

  private

  # Before filters

  def set_user
    @user = User.find(params[:user_id])
  end
end
