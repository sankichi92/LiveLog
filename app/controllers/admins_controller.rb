class AdminsController < ApplicationController
  before_action :set_user

  after_action :verify_authorized

  def create
    authorize @user, :change_status?
    @user.update_attribute(:admin, true)
    flash[:success] = t('flash.controllers.admins.created')
    redirect_to @user
  end

  def destroy
    authorize @user, :change_status?
    @user.update_attribute(:admin, false)
    flash[:success] = t('flash.controllers.admins.deleted')
    redirect_to @user
  end

  private

  def set_user
    @user = User.find(params[:user_id])
  end
end
