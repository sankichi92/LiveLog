require 'csv'

class UsersController < ApplicationController
  before_action :require_not_user_member, only: %i[new create]

  after_action :verify_authorized, only: %i[edit update]

  permits :password, :password_confirmation

  def new
  end

  def create
  end

  def edit(id)
    @user = User.find(id)
    authorize @user
  end

  def update(id)
    @user = User.find(id)
    authorize @user
    if @user.update(params.require(:user).permit(:email, :subscribing))
      redirect_to edit_user_path(@user), notice: '設定を更新しました'
    else
      render :edit, status: :unprocessable_entity
    end
  end

  private

  def require_not_user_member(member_id)
    @member = Member.find(member_id)
    redirect_to root_path, alert: 'すでにユーザー登録が完了しています' if @member.user_id
  end
end
