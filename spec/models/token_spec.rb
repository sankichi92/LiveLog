require 'rails_helper'

RSpec.describe Token, type: :model do

  let(:token) { build(:token) }

  subject { token }

  it { is_expected.to respond_to(:user_id) }
  it { is_expected.to respond_to(:user) }
  it { is_expected.to respond_to(:digest) }
  it { is_expected.to respond_to(:token) }

  it { is_expected.to be_valid }

  describe 'after saving token' do
    before { token.save }

    it 'should have present token and digest' do
      expect(token.token).not_to be_nil
      expect(token.digest).not_to be_nil
    end

    it 'should have valid token' do
      expect(token.user.valid_token?(token.token)).to be_truthy
    end
  end
end
