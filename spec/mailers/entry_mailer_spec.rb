require 'rails_helper'

RSpec.describe EntryMailer, type: :mailer do
  describe 'entry' do
    let(:applicant) { create(:user) }
    let(:player) { create(:user) }
    let(:song) { create(:song, users: [applicant, player]) }
    let(:entry) { build(:entry, applicant: applicant, song: song) }
    let(:mail) { EntryMailer.entry(entry) }

    it 'renders the headers' do
      expect(mail.subject).to eq("#{song.live_name} 曲申請「#{song.title}」")
      expect(mail.to).to eq(['pa@ku-unplugged.net'])
      expect(mail.from).to eq(['noreply@livelog.ku-unplugged.net'])
      expect(mail.cc).to eq([applicant.email])
    end

    it 'renders the text body' do
      expect(mail.text_part.body).to match(applicant.name)
      expect(mail.text_part.body).to match(song.title)
      expect(mail.text_part.body).to match(player.name)
      expect(mail.text_part.body).to match(entry.notes)
      expect(mail.text_part.body).to match(entry.preferred_rehearsal_time)
      expect(mail.text_part.body).to match(entry.preferred_performance_time)
    end

    it 'renders the html body' do
      expect(mail.html_part.body).to match(applicant.name)
      expect(mail.html_part.body).to match(CGI.escapeHTML(song.name))
      expect(mail.html_part.body).to match(player.name)
      expect(mail.html_part.body).to match(entry.notes)
      expect(mail.html_part.body).to match(entry.preferred_rehearsal_time)
      expect(mail.html_part.body).to match(entry.preferred_performance_time)
    end
  end
end
