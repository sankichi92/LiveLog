require 'rails_helper'

RSpec.describe Live, type: :model do
  let(:live) { build(:live) }

  subject { live }

  it { is_expected.to respond_to(:name) }
  it { is_expected.to respond_to(:date) }
  it { is_expected.to respond_to(:place) }
end

