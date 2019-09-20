require 'rails_helper'

RSpec.describe Playing, type: :model do

  subject { playing }

  let(:user) { create(:user) }
  let(:song) { create(:song) }
  let(:playing) { user.playings.build(song: song) }


  it { is_expected.to respond_to(:user) }
  it { is_expected.to respond_to(:song) }
  it { is_expected.to respond_to(:inst) }

  it { is_expected.to be_valid }

  describe 'validation' do
    describe 'when user id is not present' do
      before { playing.user_id = nil }

      it { is_expected.not_to be_valid }
    end

    describe 'when song id is not present' do
      before { playing.song_id = nil }

      it { is_expected.not_to be_valid }
    end

    xdescribe 'when the combination of user and song is already taken' do
      before { playing.dup.save }

      it { is_expected.not_to be_valid }
    end
  end

  describe '#save' do
    describe 'when inst includes fill-width alphabets' do
      before { playing.inst = 'Ｇｔ＆Ｖｏ' }

      it 'converts them into half-width alphabets' do
        playing.save
        expect(playing.inst).to eq 'Gt&Vo'
      end
    end

    describe 'when inst includes dot' do
      before { playing.inst = 'Ba&Cho.' }

      it 'trims the dot' do
        playing.save
        expect(playing.inst).to eq 'Ba&Cho'
      end
    end
  end

  describe '.count_insts' do
    before do
      %w[Gt Gt Vo Gt&Vo Ba&Cho Cj&Cho].each do |inst|
        create(:playing, inst: inst)
      end
    end

    it 'returns the number of occurrences of each instrument' do
      expect(described_class.all.count_insts).to match_array [['Gt', 3], ['Vo', 2], ['Cho', 2], ['Ba', 1], ['Cj', 1]]
    end
  end

  describe '.count_formations' do
    before do
      [1, 1, 1, 2, 2, 3].each do |number_of_people|
        create(:song, users: create_list(:user, number_of_people))
      end
    end

    it 'returns the number of occurrences of each formation' do
      expect(described_class.all.count_formations).to match [[1, 3], [2, 2], [3, 1]]
    end
  end
end
