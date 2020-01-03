require 'rails_helper'

RSpec.describe Song, type: :model do
  describe '#save_with_plays_attributes' do
    let(:song) { build(:song, plays_attributes: plays_attributes) }
    let(:plays_attributes) do
      {
        '0' => {
          instrument: 'Vo',
          member_id: member1_id,
        },
        '1' => {
          instrument: 'Gt',
          member_id: member2_id,
        },
      }
    end

    context 'with NOT duplicated plays_attributes' do
      let(:member1_id) { create(:member).id }
      let(:member2_id) { create(:member).id }

      it 'saves and returns true' do
        result = song.save_with_plays_attributes

        expect(result).to be true
        expect(song).to be_persisted
        expect(song.errors).to be_empty
      end
    end

    context 'with duplicated plays_attributes' do
      let(:member1_id) { create(:member).id }
      let(:member2_id) { member1_id }

      it 'returns false' do
        result = song.save_with_plays_attributes

        expect(result).to be false
        expect(song).to be_new_record
        expect(song.errors.added?(:plays, :duplicated)).to be true
      end
    end
  end

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
