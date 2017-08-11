require 'rails_helper'

RSpec.describe Token, type: :model do

  let(:token) { build(:token) }

  subject { token }

  it { is_expected.to respond_to(:user_id) }
  it { is_expected.to respond_to(:user) }
  it { is_expected.to respond_to(:digest) }

  it { is_expected.to be_valid }
end
