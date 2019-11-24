require 'csv'

class UsersController < ApplicationController
  before_action :require_not_user_member, only: %i[new create]
  before_action :require_valid_token, only: %i[new create]

  after_action :verify_authorized, only: %i[edit update]

  permits :password, :password_confirmation

  def new
    @user = @member.build_user
  end

  def create(user)
    @user = @member.build_user(user)
    @user.email = @member.invitation.email

    if @user.save
      log_in @user
      redirect_to root_path, notice: 'LiveLog へようこそ！'
    else
      render :new, status: :unprocessable_entity
    end
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

  def require_valid_token(token)
    if @member.invitation.nil? || token != @member.invitation.token
      redirect_to root_path, alert: '無効な URL です'
    end
  end
end
