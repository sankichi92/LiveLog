require 'rails_helper'

RSpec.describe SongMailer, type: :mailer do
  include Auth0UserHelper

  describe '#pickup' do
    subject(:mail) { SongMailer.pickup(song) }

    let(:song) { create(:song, name: 'くちなしの丘', artist: '原田知世', live: live, members: users.map(&:member) + [unsubscribing_user.member, member]) }
    let(:live) { create(:live, name: 'NF', date: '2019-11-23') }
    let(:users) { create_pair(:user) }
    let(:unsubscribing_user) { create(:user) }
    let(:member) { create(:member) }

    before do
      users.each_with_index do |user, i|
        stub_auth0_user(user, email: "user#{i}@example.com", subscribing: true)
      end
      stub_auth0_user(unsubscribing_user, subscribing: false)
    end

    it 'renders the headers and the body' do
      expect(mail.from).to contain_exactly 'noreply@livelog.ku-unplugged.net'
      expect(mail.bcc).to contain_exactly 'user0@example.com', 'user1@example.com'
      expect(mail.subject).to eq '「くちなしの丘」が今日のピックアップに選ばれました！'
      expect(mail.body.to_s).to eq read_fixture('pickup.txt').gsub("\n", "\r\n")
    end
  end
end
