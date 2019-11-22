class InvitationMailer < ApplicationMailer
  def invited(invitation)
    @invitation = invitation

    mail from: %("#{@invitation.inviter.member.name}" <#{ApplicationMailer::DEFAULT_FROM_EMAIL}>),
         to: @invitation.email,
         subject: 'LiveLog への招待'
  end
end
