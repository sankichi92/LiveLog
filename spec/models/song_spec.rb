require 'rails_helper'

RSpec.describe Song, type: :model do
  describe '#valid?' do
    subject(:song) { build(:song) }

    context 'when youtube_id is not valid format' do
      let(:invalid_urls) do
        %w[
          https://livelog.ku-unplugged.net/songs/1
          https://www.youtube.com/
          https://www.youtube.com/watch?v=aaa
        ]
      end

      it 'returns false' do
        invalid_urls.each do |url|
          song.youtube_id = url
          expect(song).not_to be_valid
        end
      end
    end
  end

  describe 'before_save callback: extract_youtube_id' do
    let(:urls) do
      %w[
        https://www.youtube.com/watch?v=-gKPuxV3MkY
        https://youtu.be/-gKPuxV3MkY
        https://www.youtube.com/watch?list=PLJNbijG2M7OzYyflxDhucn2aaro613QPI&v=-gKPuxV3MkY
        https://youtu.be/-gKPuxV3MkY?list=PLJNbijG2M7OzYyflxDhucn2aaro613QPI
      ]
    end

    it 'extracts the video id from youtube url' do
      song = create(:song)

      urls.each do |url|
        song.update!(youtube_id: url)
        expect(song.youtube_id).to eq '-gKPuxV3MkY'
      end
    end
  end
end
