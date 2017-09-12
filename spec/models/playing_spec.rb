require 'rails_helper'

RSpec.describe Playing, type: :model do

  let(:user) { create(:user) }
  let(:song) { create(:song) }
  let(:playing) { user.playings.build(song: song) }

  subject { playing }

  it { is_expected.to respond_to(:song) }
  it { is_expected.to respond_to(:user) }

  it { is_expected.to be_valid }

  describe 'when user id is not present' do
    before { playing.user_id = nil }
    it { is_expected.not_to be_valid }
  end

  describe 'when song id is not present' do
    before { playing.song_id = nil }
    it { is_expected.not_to be_valid }
  end

  describe 'when the combination of user and song is already taken' do
    before { playing.dup.save }
    it { is_expected.not_to be_valid }
  end
end
