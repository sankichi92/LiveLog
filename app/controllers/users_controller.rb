class UsersController < ApplicationController
  before_action :require_current_user
  before_action :require_not_logged_in_member

  permits :email

  def new
    @user = @member.user || @member.build_user
    @user.email = nil
  end

  def create(user)
    @user = @member.user || @member.build_user
    @user.assign_attributes(user)

    if @user.save
      @user.invite!
      InvitationActivityNotifyJob.perform_later(user: current_user, text: "#{@member.joined_year_and_name} を招待しました")
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
