class AdminsController < ApplicationController
  before_action :set_user

  after_action :verify_authorized

  def create
    authorize @user, :change_status?
    @user.update!(admin: true)
    flash[:success] = '管理者権限を有効にしました'
    redirect_to @user
  end

  def destroy
    authorize @user, :change_status?
    @user.update!(admin: false)
    flash[:success] = '管理者権限を無効にしました'
    redirect_to @user
  end

  private

  def set_user
    @user = User.find(params[:user_id])
  end
end
