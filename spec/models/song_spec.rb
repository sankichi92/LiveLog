require 'rails_helper'

RSpec.describe Song, type: :model do
  describe '#youtube_url=' do
    let(:song) { build(:song) }
    let(:youtube_id) { '-gKPuxV3MkY' }

    context 'with www.youtube.com url' do
      let(:urls) do
        %W[
          https://www.youtube.com/watch?v=#{youtube_id}
          https://www.youtube.com/watch?list=PLJNbijG2M7OzYyflxDhucn2aaro613QPI&v=#{youtube_id}
        ]
      end

      it 'extracts and assigns youtube_id' do
        urls.each do |url|
          song.youtube_url = url
          expect(song.youtube_id).to eq youtube_id
        end
      end
    end

    context 'with youtu.be url' do
      let(:urls) do
        %W[
          https://youtu.be/#{youtube_id}
          https://youtu.be/#{youtube_id}?list=PLJNbijG2M7OzYyflxDhucn2aaro613QPI
        ]
      end

      it 'extracts and assigns youtube_id' do
        urls.each do |url|
          song.youtube_url = url
          expect(song.youtube_id).to eq youtube_id
        end
      end
    end

    context 'with invalid url' do
      let(:urls) do
        %w[
          https://livelog.ku-unplugged.net/songs/1
          -gKPuxV3MkY
        ]
      end

      it 'does not assign youtube_id' do
        urls.each do |url|
          song.youtube_url = url
          expect(song.youtube_id).to be_nil
        end
      end
    end
  end
end
