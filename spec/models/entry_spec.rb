require 'rails_helper'

RSpec.describe Entry, type: :model do
  let(:entry) { build(:entry) }

  subject { entry }

  it { is_expected.to be_valid }

  describe 'when applicant is not present' do
    before { entry.applicant = nil }
    it { is_expected.not_to be_valid }
  end

  describe 'when song is not present' do
    before { entry.song = nil }
    it { is_expected.not_to be_valid }
  end
end
