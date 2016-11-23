require 'rails_helper'

RSpec.describe Live, type: :model do
  let(:live) { build(:live) }

  subject { live }

  it { is_expected.to respond_to(:name) }
  it { is_expected.to respond_to(:date) }
  it { is_expected.to respond_to(:place) }
  it { is_expected.to respond_to(:songs) }

  it { is_expected.to be_valid }

  describe 'when name is not present' do
    before { live.name = '' }
    it { is_expected.not_to be_valid }
  end

  describe 'when date is not present' do
    before { live.date = '' }
    it { is_expected.not_to be_valid }
  end

  describe 'when the combination of name and date is already taken' do
    before { live.dup.save }
    it { is_expected.not_to be_valid }
  end
end

