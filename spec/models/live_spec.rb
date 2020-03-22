require 'rails_helper'

RSpec.describe Live, type: :model do
  describe '#publish!', elasticsearch: true do
    subject(:publish!) { live.publish! }

    let(:live) { create(:live, :unpublished, :with_entry_guideline) }

    before do
      3.times do
        song = create(:song, :for_entry, live: live)
        create(:entry, song: song)
      end
    end

    it 'updates column `publish` and destroys entry_guideline and entries' do
      live.publish!

      expect(live.reload).to be_published
      expect(live.entry_guideline).to be_nil
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
