class AdminsController < ApplicationController
  before_action :set_user

  def create
    authorize @user, :make_admin?
    @user.update_attribute(:admin, true)
    flash[:success] = t('admin.create')
    redirect_to user_url(@user)
  end

  def destroy
    authorize @user, :make_admin?
    @user.update_attribute(:admin, false)
    flash[:success] = t('admin.destroy')
    redirect_to user_url(@user)
  end

  private

  def set_user
    @user = User.find(params[:user_id])
  end
end
