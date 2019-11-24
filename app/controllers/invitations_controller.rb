class InvitationsController < ApplicationController
  before_action :require_current_user
  before_action :require_not_user_member

  def new
    @invitation = @member.build_invitation
  end

  def create(invitation)
    @invitation = @member.build_invitation(inviter: current_user, email: invitation[:email])

    if @invitation.save
      InvitationMailer.invited(@invitation).deliver_now
      redirect_to @member, notice: '招待メールを送信しました'
    else
      render :new, status: :unprocessable_entity
    end
  end

  private

  # region Filters

  def require_not_user_member(member_id)
    @member = Member.find(member_id)
    redirect_to @member, alert: 'すでに招待が完了しています' unless @member.user_id.nil?
  end

  # endregion
end
