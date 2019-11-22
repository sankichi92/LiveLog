require 'csv'

class UsersController < ApplicationController
  permits :email, :subscribing

  after_action :verify_authorized

  def new
  end

  def edit(id)
    @user = User.find(id)
    authorize @user
  end

  def update(id, user)
    @user = User.find(id)
    authorize @user
    if @user.update(user)
      flash[:success] = '設定を更新しました'
      redirect_to edit_user_path(@user)
    else
      render :edit, status: :unprocessable_entity
    end
  end
end
