require 'rails_helper'

RSpec.describe SongMailer, type: :mailer do

  describe 'entry' do
    let(:applicant) { create(:user) }
    let(:notes) { 'Vo がタンバリンを使うかもしれません' }
    let(:song) { create(:song, notes: notes) }
    let(:player) { create(:user) }
    let(:mail) { SongMailer.entry(song, applicant) }

    before do
      [applicant, player].each { |u| create(:playing, song: song, user: u) }
    end

    it 'renders the headers' do
      expect(mail.subject).to eq("#{song.live.name} 曲申請「#{song.title}」")
      expect(mail.to).to eq(['pa@ku-unplugged.net'])
      expect(mail.from).to eq(['noreply@livelog.ku-unplugged.net'])
      expect(mail.reply_to).to eq([applicant.email])
    end

    it 'renders the text body' do
      expect(mail.text_part.body).to match(applicant.formal_name)
      expect(mail.text_part.body).to match(song.title)
      expect(mail.text_part.body).to match(player.formal_name)
      expect(mail.text_part.body).to match(notes)
    end

    it 'renders the html body' do
      expect(mail.html_part.body).to match(applicant.formal_name)
      expect(mail.html_part.body).to match(song.title)
      expect(mail.html_part.body).to match(player.formal_name)
      expect(mail.html_part.body).to match(notes)
    end
  end
end
