require 'rails_helper'

RSpec.describe User, type: :model do
  subject { user }

  let(:user) { build(:user) }


  it { is_expected.to respond_to(:email) }
  it { is_expected.to respond_to(:admin) }
  it { is_expected.to respond_to(:subscribing) }

  it { is_expected.to be_valid }
  it { is_expected.not_to be_admin }

  describe 'with admin attribute set to "true"' do
    before do
      user.save!
      user.toggle(:admin)
    end

    it { is_expected.to be_admin }
  end

  describe '#save' do
    describe 'with email address including upper-case' do
      let(:mixed_case_email) { 'Foo@ExAMPle.CoM' }

      before { user.email = mixed_case_email }

      it 'is saved as all lower-case' do
        user.save
        expect(user.reload.email).to eq mixed_case_email.downcase
      end
    end
  end
end
