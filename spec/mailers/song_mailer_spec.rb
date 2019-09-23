require 'rails_helper'

RSpec.describe SongMailer, type: :mailer do
  describe 'pickup_song' do
    let(:users) { create_list(:user, 3, subscribing: true) }
    let(:inactivated_user) { create(:user, :inactivated) }
    let(:unsubscribing_user) { create(:user, subscribing: false) }
    let(:song) { create(:song, users: [users, inactivated_user, unsubscribing_user].flatten) }
    let(:mail) { described_class.pickup_song(song) }

    it 'renders the headers' do
      expect(mail.subject).to eq("「#{song.name}」が今日のピックアップに選ばれました！")
      expect(mail.from).to eq(['noreply@livelog.ku-unplugged.net'])
      expect(mail.bcc).to eq(users.map(&:email))
    end

    it 'renders the text body' do
      expect(mail.text_part.body).to match(song.title)
      expect(mail.text_part.body).to match(root_url)
    end

    it 'renders the html body' do
      expect(mail.html_part.body).to match(CGI.escapeHTML(song.title))
      expect(mail.html_part.body).to match(root_url)
    end
  end
end
