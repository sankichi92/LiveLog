require 'rails_helper'

RSpec.describe Song, type: :model do

  let(:live) { create(:live) }
  let(:song) { build(:song, live: live) }

  subject { song }

  it { is_expected.to respond_to(:name) }
  it { is_expected.to respond_to(:artist) }
  it { is_expected.to respond_to(:youtube_id) }
  it { is_expected.to respond_to(:order) }
  it { is_expected.to respond_to(:time) }
  it { is_expected.to respond_to(:live_id) }
  it { is_expected.to respond_to(:live) }
  it { is_expected.to respond_to(:playings) }
  it { is_expected.to respond_to(:users) }
  it { is_expected.to respond_to(:status) }
  it { is_expected.to respond_to(:open?) }
  it { is_expected.to respond_to(:closed?) }
  it { is_expected.to respond_to(:secret?) }
  it { is_expected.to respond_to(:comment) }
  it { expect(song.live).to eq live }

  it { is_expected.to be_valid }

  describe 'when user_id is not present' do
    before { song.live_id = nil }
    it { is_expected.not_to be_valid }
  end

  describe 'when name is not present' do
    before { song.name = '' }
    it { is_expected.not_to be_valid }
  end

  describe 'when youtube url format is invalid' do
    it 'should be invalid' do
      urls = %w(http://livelog.ku-unplugged.net/
                https://www.youtube.com/
                https://www.youtube.com/watch?v=aaa)
      urls.each do |invalid_address|
        song.youtube_id = invalid_address
        expect(song).not_to be_valid(:update)
      end
    end
  end

  describe 'when youtube url format is valid' do
    it 'should be valid' do
      urls = %w(https://www.youtube.com/watch?v=-gKPuxV3MkY
                https://youtu.be/-gKPuxV3MkY
                https://www.youtube.com/watch?list=PLJNbijG2M7OzYyflxDhucn2aaro613QPI&v=-gKPuxV3MkY
                https://youtu.be/-gKPuxV3MkY?list=PLJNbijG2M7OzYyflxDhucn2aaro613QPI)
      urls.each do |valid_address|
        song.youtube_id = valid_address
        expect(song).to be_valid(:update)
      end
    end
  end
end
