require 'rails_helper'

RSpec.describe Live, type: :model do
  describe 'validations' do
    subject(:live) { build(:live) }

    it { is_expected.to be_valid }

    describe 'when name is blank' do
      before { live.name = '' }

      it { is_expected.not_to be_valid }
    end

    describe 'when date is blank' do
      before { live.date = '' }

      it { is_expected.not_to be_valid }
    end

    describe 'when the combination of name and date is already taken' do
      before { live.dup.save }

      it { is_expected.not_to be_valid }
    end

    describe 'when album_url is invalid' do
      before { live.album_url = 'invalid' }

      it { is_expected.not_to be_valid }
    end
  end

  describe 'song associations' do
    let(:live) { create(:live) }

    before do
      create(:song, live: live)
    end

    it 'raises an exception when live is deleted with songs' do
      expect { live.destroy! }.to raise_exception ActiveRecord::DeleteRestrictionError
    end
  end
end
