require 'rails_helper'

RSpec.describe EntryMailer, type: :mailer do
  include Auth0UserHelper

  describe 'entry' do
    let(:applicant) { create(:user) }
    let(:applicant_email) { 'applicant@example.com' }
    let(:player) { create(:user) }
    let(:song) { create(:song, members: [applicant.member, player.member]) }
    let(:entry) { build(:entry, applicant: applicant, song: song) }
    let(:mail) { EntryMailer.entry(entry) }

    before do
      stub_auth0_user(applicant, email: applicant_email)
    end

    it 'renders the headers' do
      expect(mail.subject).to eq("#{song.live.name} 曲申請「#{song.title}」")
      expect(mail.to).to eq(['pa@ku-unplugged.net'])
      expect(mail.from).to eq(['noreply@livelog.ku-unplugged.net'])
      expect(mail.cc).to eq([applicant_email])
    end

    it 'renders the text body' do
      expect(mail.text_part.body).to include(applicant.member.name)
      expect(mail.text_part.body).to include(song.title)
      expect(mail.text_part.body).to include(player.member.name)
      expect(mail.text_part.body).to include(entry.notes)
      expect(mail.text_part.body).to include(entry.preferred_rehearsal_time)
      expect(mail.text_part.body).to include(entry.preferred_performance_time)
    end

    it 'renders the html body' do
      expect(mail.html_part.body).to include(applicant.member.name)
      expect(mail.html_part.body).to include(CGI.escapeHTML(song.name))
      expect(mail.html_part.body).to include(player.member.name)
      expect(mail.html_part.body).to include(entry.notes)
      expect(mail.html_part.body).to include(entry.preferred_rehearsal_time)
      expect(mail.html_part.body).to include(entry.preferred_performance_time)
    end
  end
end
