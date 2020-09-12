# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Play, type: :model do
  describe '.count_by_divided_instrument' do
    before do
      %w[Gt Gt Vo Gt&Vo Ba&Cho Cj&Cho].each do |instrument|
        create(:play, instrument: instrument)
      end
    end

    it 'returns the number of occurrences of each instrument' do
      result = described_class.all.count_by_divided_instrument

      expect(result).to eq('Gt' => 3, 'Vo' => 2, 'Cho' => 2, 'Ba' => 1, 'Cj' => 1)
    end
  end

  describe '.count_formations' do
    before do
      [1, 1, 1, 2, 2, 3].each do |number_of_people|
        create(:song, members: create_list(:member, number_of_people))
      end
    end

    it 'returns the number of occurrences of each formation' do
      result = described_class.all.count_formations

      expect(result).to eq(1 => 3, 2 => 2, 3 => 1)
    end
  end

  describe 'before_save callback: format_instrument' do
    let(:play) { build(:play, instrument: instrument) }

    describe 'with instrument including fill-width alphabets' do
      let(:instrument) { 'Ｇｔ＆Ｖｏ' }

      it 'converts them into half-width alphabets' do
        play.save

        expect(play.instrument).to eq 'Gt&Vo'
      end
    end

    describe 'with instrument including dot' do
      let(:instrument) { 'Ba&Cho.' }

      it 'trims the dot' do
        play.save

        expect(play.instrument).to eq 'Ba&Cho'
      end
    end
  end
end
