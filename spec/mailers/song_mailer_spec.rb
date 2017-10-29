require 'rails_helper'

RSpec.describe SongMailer, type: :mailer do

  describe 'entry' do
    let(:applicant) { create(:user) }
    let(:notes) { 'Vo がタンバリンを使うかもしれません' }
    let(:rehearsal_time) { '20:00 以降でお願いします' }
    let(:play_time) { '22:00まででお願いします' }
    let(:song) { create(:song, notes: notes, rehearsal_time: rehearsal_time, play_time: play_time) }
    let(:player) { create(:user) }
    let(:mail) { SongMailer.entry(song, applicant) }

    before do
      [applicant, player].each { |u| create(:playing, song: song, user: u) }
    end

    it 'renders the headers' do
      expect(mail.subject).to eq("#{song.live_name} 曲申請「#{song.title}」")
      expect(mail.to).to eq(['pa@ku-unplugged.net'])
      expect(mail.from).to eq(['noreply@livelog.ku-unplugged.net'])
      expect(mail.reply_to).to eq([applicant.email])
    end

    it 'renders the text body' do
      expect(mail.text_part.body).to match(applicant.name)
      expect(mail.text_part.body).to match(song.title)
      expect(mail.text_part.body).to match(player.name)
      expect(mail.text_part.body).to match(notes)
      expect(mail.text_part.body).to match(rehearsal_time)
      expect(mail.text_part.body).to match(play_time)
    end

    it 'renders the html body' do
      expect(mail.html_part.body).to match(applicant.name)
      expect(mail.html_part.body).to match(song.name)
      expect(mail.html_part.body).to match(player.name)
      expect(mail.html_part.body).to match(notes)
      expect(mail.html_part.body).to match(rehearsal_time)
      expect(mail.html_part.body).to match(play_time)
    end
  end
end
