require 'rails_helper'

RSpec.describe Song, type: :model do

  let(:live) { create(:live) }
  let(:song) { build(:song, live: live) }

  subject { song }

  it { is_expected.to respond_to(:name) }
  it { is_expected.to respond_to(:artist) }
  it { is_expected.to respond_to(:youtube_url) }
  it { is_expected.to respond_to(:order) }
  it { is_expected.to respond_to(:time) }
  it { is_expected.to respond_to(:live_id) }
  it { is_expected.to respond_to(:live) }
  it { expect(song.live).to eq live }

  it { is_expected.to be_valid }

  describe 'when user_id is not present' do
    before { song.live_id = nil }
    it { is_expected.not_to be_valid }
  end
end
