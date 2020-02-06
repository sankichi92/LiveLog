class UsersController < ApplicationController
  before_action :require_current_user
  before_action :require_not_logged_in_member

  permits :email

  def new
    @user = @member.user || @member.build_user
  end

  def create(user)
    @user = @member.user || @member.build_user
    @user.assign_attributes(user)

    if @user.save(context: :invite)
      @user.invite!
      redirect_to @member, notice: '招待しました'
    else
      render :new, status: :unprocessable_entity
    end
  end

  private

  # region Filters

  def require_not_logged_in_member(member_id)
    @member = Member.find(member_id)
    if @member.user && (@member.user.activated || @member.user.auth0_user.email_verified? || @member.user.auth0_user.has_logged_in?)
      @member.user.activate! unless @member.user.activated?
      redirect_to @member, alert: 'すでにユーザー登録が完了しています'
    end
  end

  # endregion
end
