require 'rails_helper'

RSpec.describe Entry, type: :model do

  let(:entry) { build(:entry) }

  subject { entry }

  it { is_expected.to respond_to(:applicant) }
  it { is_expected.to respond_to(:song) }
  it { is_expected.to respond_to(:preferred_rehearsal_time) }
  it { is_expected.to respond_to(:preferred_performance_time) }
  it { is_expected.to respond_to(:notes) }
  it { is_expected.to respond_to(:applicant_name) }
  it { is_expected.to respond_to(:applicant_email) }
  it { is_expected.to respond_to(:applicant_joined) }
  it { is_expected.to respond_to(:live) }
  it { is_expected.to respond_to(:live_name) }
  it { is_expected.to respond_to(:live_title) }
  it { is_expected.to respond_to(:title) }
  it { is_expected.to respond_to(:name) }
  it { is_expected.to respond_to(:artist) }
  it { is_expected.to respond_to(:playings) }

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
