require 'rails_helper'

RSpec.describe SongMailer, type: :mailer do

  describe 'entry' do
    let(:applicant) { create(:user) }
    let(:song) { create(:song) }
    let(:notes) { 'Vo がタンバリンを使うかもしれません' }
    let(:mail) { SongMailer.entry(song, applicant, notes) }

    it 'renders the headers' do
      expect(mail.subject).to eq("#{song.live.title} 曲申請「#{song.title}」")
      expect(mail.to).to eq(['pa@ku-unplugged.net'])
      expect(mail.from).to eq([applicant.email])
    end

    # TODO: Resolve https://github.com/sankichi92/LiveLog/issues/85 and test the body
  end
end
