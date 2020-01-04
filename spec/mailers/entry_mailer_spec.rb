require 'rails_helper'

RSpec.describe EntryMailer, type: :mailer do
  include Auth0UserHelper

  describe '#created' do
    subject(:mail) { EntryMailer.created(entry) }

    let(:entry) { create(:entry, member: user.member) }
    let(:user) { create(:user) }

    context 'when submitter has verified email' do
      before do
        stub_auth0_user(user, email: 'submitter@example.com', email_verified: true)
      end

      it 'renders the headers with bcc' do
        expect(mail.from).to contain_exactly ApplicationMailer::DEFAULT_FROM_EMAIL
        expect(mail.to).to contain_exactly 'pa@ku-unplugged.net'
        expect(mail.bcc).to contain_exactly 'submitter@example.com'
        expect(mail.subject).to eq "新規エントリー: #{entry.song.live.name}「#{entry.song.title}」"
      end
    end

    context 'when submitter does not have verified email' do
      before do
        stub_auth0_user(user, email_verified: false)
      end

      it 'renders the headers without bcc' do
        expect(mail.from).to contain_exactly ApplicationMailer::DEFAULT_FROM_EMAIL
        expect(mail.to).to contain_exactly 'pa@ku-unplugged.net'
        expect(mail.bcc).to be_empty
        expect(mail.subject).to eq "新規エントリー: #{entry.song.live.name}「#{entry.song.title}」"
      end
    end
  end
end
