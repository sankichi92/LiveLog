require 'rails_helper'

RSpec.describe User, type: :model do
  describe '#invite!' do
    let(:user) { create(:user, email: email) }
    let(:email) { 'user@example.com' }

    let(:auth0_client) { spy(:app_auth0_client) }

    before do
      allow(AppAuth0Client).to receive(:instance).and_return(auth0_client)
    end

    context 'when a corresponding Auth0 user does not exist' do
      before do
        allow(auth0_client).to receive(:user).and_raise(Auth0::NotFound.new('The user does not exist.'))
        allow(auth0_client).to receive(:create_user).and_return('email' => email)
      end

      it 'creates an Auth0 user and sends a password reset email' do
        user.invite!

        expect(auth0_client).to have_received(:user).once
        expect(auth0_client).to have_received(:create_user).with(anything, hash_including(email: email)).once
        expect(auth0_client).to have_received(:change_password).with(email, nil).once
      end
    end

    context 'when a corresponding Auth0 user exists and the email is the same as theirs' do
      before do
        allow(auth0_client).to receive(:user).and_return('email' => email)
      end

      it 'sends a password reset email' do
        user.invite!

        expect(auth0_client).to have_received(:user).once
        expect(auth0_client).to have_received(:change_password).with(email, nil).once
      end
    end

    context 'when a corresponding Auth0 user exists and the email is different from theirs' do
      before do
        allow(auth0_client).to receive(:user).and_return('email' => 'different@example.com')
      end

      it "updates the Auth0 user's email and sends a password reset email" do
        user.invite!

        expect(auth0_client).to have_received(:user).once
        expect(auth0_client).to have_received(:patch_user).with(user.auth0_id, email: email, verify_email: false).once
        expect(auth0_client).to have_received(:change_password).with(email, nil).once
      end
    end

    context 'when email is invalid' do
      let(:email) { 'invalid' }

      it 'raises ActiveRecord::RecordInvalid' do
        expect { user.invite! }.to raise_error ActiveRecord::RecordInvalid

        expect(auth0_client).not_to have_received(:user)
        expect(auth0_client).not_to have_received(:change_password)
      end
    end
  end
end
