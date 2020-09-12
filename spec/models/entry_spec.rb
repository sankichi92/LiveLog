# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Entry, type: :model do
  describe '#in_playable_time?' do
    subject(:in_playable_time?) { entry.in_playable_time? }

    let(:entry) { build(:entry, song: song, playable_times_count: 0) }
    let(:song) { create(:song, :for_entry, live: live, time: song_time) }
    let(:live) { create(:live, :unpublished, date: live_date) }
    let(:live_date) { Time.zone.today }

    before do
      entry.playable_times.build(range: playable_time_range)
    end

    context 'when song.time is present and playable_time including the time exists' do
      let(:song_time) { live_date.in_time_zone.change(hour: 19) }
      let(:playable_time_range) { (song_time - 1.hour)...(song_time + 1.hour) }

      it { is_expected.to be true }
    end

    context 'when song.time is present and playable_time including the time does not exist' do
      let(:song_time) { live_date.in_time_zone.change(hour: 19) }
      let(:playable_time_range) { (song_time - 3.hours)...(song_time - 1.hour) }

      it { is_expected.to be false }
    end

    context 'when song.time is blank and playable_time included within live.date exists' do
      let(:song_time) { nil }
      let(:playable_time_range) { live_date.in_time_zone.change(hour: 19)...live_date.in_time_zone.change(hour: 21) }

      it { is_expected.to be true }
    end

    context 'when song.time is blank and playable_time included within live.date does not exist' do
      let(:song_time) { nil }
      let(:playable_time_range) { (live_date - 1.day).in_time_zone.change(hour: 19)...(live_date - 1.day).in_time_zone.change(hour: 21) }

      it { is_expected.to be false }
    end
  end
end
