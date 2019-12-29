require 'rails_helper'

RSpec.describe SongOrderFixBatch, type: :batch do
  describe '#run' do
    subject(:batch) { SongOrderFixBatch.new }

    before do
      ENV['DRY_RUN'] = 'false'

      create_pair(:live).each do |live|
        5.times.each do |i|
          create(:song, live: live, order: 1, time: Time.zone.now + i.hours)
        end
      end
    end

    after do
      ENV['DRY_RUN'] = nil
    end

    it 'fixes `order` columns' do
      expect { batch.run }.to change { batch.target_live_ids.size }.from(2).to(0)
    end
  end
end
