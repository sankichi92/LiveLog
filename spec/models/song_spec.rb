require 'rails_helper'

RSpec.describe Song, type: :model do
  subject { song }

  let(:song) { build(:song, live: create(:live)) }


  it { is_expected.to respond_to(:name) }
  it { is_expected.to respond_to(:artist) }
  it { is_expected.to respond_to(:youtube_id) }
  it { is_expected.to respond_to(:live) }
  it { is_expected.to respond_to(:order) }
  it { is_expected.to respond_to(:time) }
  it { is_expected.to respond_to(:status) }
  it { is_expected.to respond_to(:comment) }
  it { is_expected.to respond_to(:original) }
  it { is_expected.to respond_to(:audio) }
  it { is_expected.to respond_to(:playings) }

  it { is_expected.to be_valid }

  describe 'validation' do
    describe 'when live_id is not present' do
      before { song.live_id = nil }

      it { is_expected.not_to be_valid }
    end

    describe 'when name is not present' do
      before { song.name = '' }

      it { is_expected.not_to be_valid }
    end

    describe 'when youtube url format is invalid' do
      let(:urls) do
        %w[http://livelog.ku-unplugged.net/
           https://www.youtube.com/
           https://www.youtube.com/watch?v=aaa]
      end

      it 'is invalid' do
        urls.each do |url|
          song.youtube_id = url
          expect(song).not_to be_valid(:update)
        end
      end
    end
  end

  describe '#save' do
    describe 'with valid youtube url' do
      let(:urls) do
        %w[https://www.youtube.com/watch?v=-gKPuxV3MkY
           https://youtu.be/-gKPuxV3MkY
           https://www.youtube.com/watch?list=PLJNbijG2M7OzYyflxDhucn2aaro613QPI&v=-gKPuxV3MkY
           https://youtu.be/-gKPuxV3MkY?list=PLJNbijG2M7OzYyflxDhucn2aaro613QPI]
      end

      before { song.save }

      it 'extracts the id from the url' do
        urls.each do |url|
          song.update(youtube_id: url)
          expect(song.youtube_id).to eq '-gKPuxV3MkY'
        end
      end
    end
  end
end
