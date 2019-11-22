require 'rails_helper'

RSpec.describe InvitationMailer, type: :mailer do
  describe '#invited' do
    subject(:mail) { InvitationMailer.invited(invitation) }

    let(:invitation) { create(:invitation, member: member, inviter: inviter, token: 'token') }
    let(:member) { create(:member, id: 10000, joined_year: 2019, name: 'ギータ') }
    let(:inviter) { create(:user, member: create(:member, joined_year: 2018, name: 'エリザベス')) }

    it 'renders the headers and the body' do
      expect(mail.subject).to eq 'LiveLog への招待'
      expect(mail.to).to eq [invitation.email]
      expect(mail.from).to eq [ApplicationMailer::DEFAULT_FROM_EMAIL]
      expect(mail.body.to_s).to eq read_fixture('invited.txt').gsub("\n", "\r\n")
    end
  end
end
