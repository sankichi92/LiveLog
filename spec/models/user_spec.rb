require 'rails_helper'

RSpec.describe User, type: :model do
  subject { user }

  let(:user) { build(:user) }


  it { is_expected.to respond_to(:email) }
  it { is_expected.to respond_to(:password_digest) }
  it { is_expected.to respond_to(:password) }
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

  describe '#authenticate' do
    before { user.save }

    let(:found_user) { User.find_by(email: user.email) }

    describe 'with valid password' do
      it { is_expected.to eq found_user.authenticate(user.password) }
    end

    describe 'with invalid password' do
      let(:user_for_invalid_password) { found_user.authenticate('invalid') }

      it { is_expected.not_to eq user_for_invalid_password }
      specify { expect(user_for_invalid_password).to be_falsey }
    end
  end
end
