# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Live do
  describe '#publish!', elasticsearch: true do
    subject(:publish!) { live.publish! }

    let(:live) { create(:live, :unpublished, :with_entry_guideline) }

    before do
      3.times do
        song = create(:song, :for_entry, live:)
        create(:entry, song:)
      end
    end

    it 'updates column `publish` and destroys entry_guideline and entries' do
      live.publish!

      expect(live.reload).to be_published
      expect(live.entry_guideline).to be_nil
      expect(live.songs.filter_map(&:entry)).to be_empty
    end
  end
end
