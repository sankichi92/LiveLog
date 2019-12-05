require 'rails_helper'

RSpec.describe SongMailer, type: :mailer do
  include Auth0UserHelper

  describe 'pickup_song' do
    let(:users) { create_list(:user, 3) }
    let(:no_user_member) { create(:member) }
    let(:unsubscribing_user) { create(:user) }
    let(:song) { create(:song, members: [users.map(&:member), no_user_member, unsubscribing_user.member].flatten) }
    let(:mail) { SongMailer.pickup_song(song) }

    before do
      users.each do |user|
        stub_auth0_user(user, subscribing: true)
      end
      stub_auth0_user(unsubscribing_user, subscribing: false)
    end

    it 'renders the headers' do
      expect(mail.subject).to eq("「#{song.name}」が今日のピックアップに選ばれました！")
      expect(mail.from).to eq(['noreply@livelog.ku-unplugged.net'])
      expect(mail.bcc.size).to eq users.size
    end

    it 'renders the text body' do
      expect(mail.text_part.body).to include(song.title)
      expect(mail.text_part.body).to include(root_url)
    end

    it 'renders the html body' do
      expect(mail.html_part.body).to include(CGI.escapeHTML(song.title))
      expect(mail.html_part.body).to include(root_url)
    end
  end
end
