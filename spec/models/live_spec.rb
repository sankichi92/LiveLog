require 'rails_helper'

RSpec.describe Live, type: :model do
  describe '#publish!', elasticsearch: true do
    subject(:publish!) { live.publish! }

    let(:live) { create(:live, :unpublished) }

    before do
      3.times do
        song = create(:song, :unpublished, live: live)
        create(:entry, song: song)
      end
    end

    it 'updates column `publish` and destroys entries' do
      live.publish!

      expect(live.reload).to be_published
      expect(live.songs.map(&:entry).compact).to be_empty
    end

    context 'when already published' do
      before do
        live.publish!
      end

      it 'raise AlreadyPublishedError' do
        expect { live.publish! }.to raise_error Live::AlreadyPublishedError
      end
    end
  end
end
