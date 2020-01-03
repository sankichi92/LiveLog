require 'rails_helper'

RSpec.describe Play, type: :model do

  subject(:play) { build(:play, song: song, member: member) }

  let(:song) { create(:song) }
  let(:member) { create(:member) }

  describe '#save' do
    describe 'when inst includes fill-width alphabets' do
      before { play.inst = 'Ｇｔ＆Ｖｏ' }

      it 'converts them into half-width alphabets' do
        play.save
        expect(play.inst).to eq 'Gt&Vo'
      end
    end

    describe 'when inst includes dot' do
      before { play.inst = 'Ba&Cho.' }

      it 'trims the dot' do
        play.save
        expect(play.inst).to eq 'Ba&Cho'
      end
    end
  end

  describe '.count_by_divided_instrument' do
    before do
      %w[Gt Gt Vo Gt&Vo Ba&Cho Cj&Cho].each do |inst|
        create(:play, inst: inst)
      end
    end

    it 'returns the number of occurrences of each instrument' do
      expect(Play.all.count_by_divided_instrument).to match_array [['Gt', 3], ['Vo', 2], ['Cho', 2], ['Ba', 1], ['Cj', 1]]
    end
  end

  describe '.count_formations' do
    before do
      [1, 1, 1, 2, 2, 3].each do |number_of_people|
        create(:song, members: create_list(:member, number_of_people))
      end
    end

    it 'returns the number of occurrences of each formation' do
      expect(Play.all.count_formations).to match [[1, 3], [2, 2], [3, 1]]
    end
  end
end
