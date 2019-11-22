require 'rails_helper'

RSpec.describe User, type: :model do
  subject { user }

  let(:user) { build(:user) }


  it { is_expected.to respond_to(:email) }
  it { is_expected.to respond_to(:password_digest) }
  it { is_expected.to respond_to(:password) }
  it { is_expected.to respond_to(:password_confirmation) }
  it { is_expected.to respond_to(:remember_digest) }
  it { is_expected.to respond_to(:admin) }
  it { is_expected.to respond_to(:reset_digest) }
  it { is_expected.to respond_to(:reset_sent_at) }
  it { is_expected.to respond_to(:songs) }
  it { is_expected.to respond_to(:public) }
  it { is_expected.to respond_to(:avatar) }
  it { is_expected.to respond_to(:subscribing) }
  it { is_expected.to respond_to(:playings) }

  it { is_expected.to be_valid }
  it { is_expected.not_to be_admin }

  describe 'with admin attribute set to "true"' do
    before do
      user.save!
      user.toggle(:admin)
    end

    it { is_expected.to be_admin }
  end

  describe 'validation' do
    describe 'when email is too long' do
      before { user.email = 'a' * 244 + '@ku-unplugged.net' }

      it { is_expected.not_to be_valid(:update) }
    end

    describe 'when email format is invalid' do
      let(:addresses) { %w[user@foo,com user_at_foo.org example.user@foo. foo@bar_baz.com foo@bar+baz.com] }

      it 'is invalid' do
        addresses.each do |invalid_address|
          user.email = invalid_address
          expect(user).not_to be_valid(:update)
        end
      end
    end

    describe 'when email format is valid' do
      let(:addresses) { %w[user@foo.COM A_US-ER@f.b.org frst.lst@foo.jp a+b@baz.cn] }

      it 'is valid' do
        addresses.each do |valid_address|
          user.email = valid_address
          expect(user).to be_valid(:update)
        end
      end
    end

    describe 'when email address is already taken' do
      before do
        user_with_same_email = user.dup
        user_with_same_email.email = user.email.upcase
        user_with_same_email.save
      end

      it { is_expected.not_to be_valid(:update) }
    end
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

  describe '#authenticated?' do
    it 'returns false for a user with nil digest' do
      expect(user).not_to be_authenticated(:remember, '')
    end
  end
end
