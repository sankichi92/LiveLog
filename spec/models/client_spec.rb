require 'rails_helper'

RSpec.describe Client, type: :model do
  describe '#create_auth0_client!' do
    let(:client) { build(:client, auth0_id: nil) }

    let(:auth0_client) { spy(:app_auth0_client) }

    before do
      allow(auth0_client).to receive(:create_client).and_return({ 'client_id' => 'auth0_client_id' })
      allow(AppAuth0Client).to receive(:instance).and_return(auth0_client)
    end

    it 'requests Auth0 to create a client and saves returned client_id' do
      client.create_auth0_client!

      expect(auth0_client).to have_received(:create_client).with(client.name, app_type: client.app_type)
      expect(client).to be_persisted
      expect(client.auth0_id).to eq 'auth0_client_id'
    end

    context 'when auth0_id already exists' do
      before do
        client.auth0_id = 'auth0_client_id'
      end

      it 'raises Client::AlreadyCreatedError' do
        expect { client.create_auth0_client! }.to raise_error(Client::AlreadyCreatedError)

        expect(auth0_client).not_to have_received(:create_client)
      end
    end

    context 'with invalid app_type' do
      before do
        client.app_type = 'invalid'
      end

      it 'raises ActiveRecord::RecordInvalid' do
        expect { client.create_auth0_client! }.to raise_error(ActiveRecord::RecordInvalid)

        expect(auth0_client).not_to have_received(:create_client)
      end
    end
  end

  describe '#create_livelog_grant!' do
    let(:client) { create(:client, livelog_grant_id: nil) }

    let(:auth0_client) { spy(:app_auth0_client) }

    before do
      allow(auth0_client).to receive(:create_client_grant).and_return({ 'id' => 'auth0_grant_id' })
      allow(AppAuth0Client).to receive(:instance).and_return(auth0_client)
    end

    it 'requests Auth0 to create a grant and saves returned id' do
      client.create_livelog_grant!

      expect(auth0_client).to have_received(:create_client_grant).with(hash_including(client_id: client.auth0_id))
      expect(client.livelog_grant_id).to eq 'auth0_grant_id'
    end

    context 'when livelog_grant_id already exists' do
      before do
        client.livelog_grant_id = 'auth0_grant_id'
      end

      it 'raises Client::AlreadyCreatedError' do
        expect { client.create_livelog_grant! }.to raise_error(Client::AlreadyCreatedError)

        expect(auth0_client).not_to have_received(:create_client_grant)
      end
    end
  end
end
