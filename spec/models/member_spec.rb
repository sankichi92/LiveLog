require 'rails_helper'

RSpec.describe Member, type: :model do
  describe '#create_user_with_auth0!' do
    let(:member) { create(:member) }
    let(:email) { 'user@example.com' }

    let(:auth0_client) { spy(:app_auth0_client) }

    before do
      allow(AppAuth0Client).to receive(:instance).and_return(auth0_client)
    end

    it 'creates a LiveLog user and requests Auth0 to create a user' do
      member.create_user_with_auth0!(email)

      expect(member.reload.user).to be_persisted
      expect(auth0_client).to have_received(:create_user).with(anything, hash_including(email: email)).once
    end

    context 'when Auth0 responds 400' do
      before do
        allow(auth0_client).to receive(:create_user).and_raise(Auth0::BadRequest, '400')
      end

      it 'does not create a LiveLog user' do
        expect { member.create_user_with_auth0!(email) }.to raise_exception Auth0::BadRequest

        expect(member.reload.user).to be_nil
      end
    end
  end
end
