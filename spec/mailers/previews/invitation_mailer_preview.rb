# Preview all emails at http://localhost:3000/rails/mailers/invitation_mailer
class InvitationMailerPreview < ActionMailer::Preview
  # Preview this email at http://localhost:3000/rails/mailers/invitation_mailer/invited
  def invited
    invitation = Invitation.last || FactoryBot.build(:invitation, member: Member.last)
    InvitationMailer.invited(invitation)
  end
end
