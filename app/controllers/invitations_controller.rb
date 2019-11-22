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
      flash[:success] = '招待メールを送信しました'
      redirect_to @member
    else
      render :new, status: :unprocessable_entity
    end
  end

  private

  # region Filters

  def require_not_user_member(member_id)
    @member = Member.find(member_id)
    unless @member.user_id.nil?
      flash[:danger] = 'すでに招待が完了しています'
      redirect_to @member
    end
  end

  # endregion
end
