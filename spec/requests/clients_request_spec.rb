require 'rails_helper'

RSpec.describe 'clients request:', type: :request do
  include Auth0ClientHelper

  describe 'GET /clients' do
    before do
      create_pair(:client)
    end

    it 'responds 200' do
      get clients_path

      expect(response).to have_http_status :ok
    end
  end

  describe 'GET /clients/new' do
    let(:user) { create(:user) }

    before do
      create(:developer, user: user)
      log_in_as user
    end

    it 'responds 200' do
      get new_client_path

      expect(response).to have_http_status :ok
    end

    context 'without developer' do
      before do
        user.developer.destroy!
      end

      it 'redirects to /clients' do
        get new_client_path

        expect(response).to redirect_to clients_path
      end
    end
  end

  describe 'POST /clients' do
    let(:developer) { create(:developer) }
    let(:params) do
      {
        client: {
          name: name,
          app_type: 'regular_web',
        },
      }
    end

    let(:auth0_client) do
      double(:auth0_client).tap do |auth0_client|
        allow(auth0_client).to receive(:create_client).and_return({ 'client_id' => 'auth0_client_id' })
        allow(auth0_client).to receive(:create_client_grant).and_return({ 'id' => 'auth0_grant_id' })
      end
    end

    before do
      allow(Octokit::Client).to receive(:new).with(access_token: developer.github_access_token).and_return(
        double(:octokit_client, user: { avatar_url: 'https://example.com/github_avatar_url' }),
      )
      allow(AppAuth0Client).to receive(:instance).and_return(auth0_client)

      log_in_as developer.user
    end

    context 'with valid params' do
      let(:name) { 'LiveLog' }

      it 'creates a client and redirects to /clients' do
        expect { post clients_path, params: params }.to change(Client, :count).by(1)

        expect(response).to have_http_status :redirect
      end
    end

    context 'with invalid params' do
      let(:name) { '' }

      it 'responds 422' do
        expect { post clients_path, params: params }.not_to change(Client, :count)

        expect(response).to have_http_status :unprocessable_entity
      end
    end
  end

  describe 'GET /clients/:id/edit' do
    let(:client) { create(:client) }

    before do
      stub_auth0_client(client)

      log_in_as client.developer.user
    end

    it 'responds 200' do
      get edit_client_path(client)

      expect(response).to have_http_status :ok
    end

    context 'without owner' do
      before do
        log_in_as create(:user)
      end

      it 'redirects to /clients' do
        get edit_client_path(client)

        expect(response).to redirect_to clients_path
      end
    end
  end

  describe 'PATCH /clients/:id' do
    let(:client) { create(:client) }
    let(:params) do
      {
        client: {
          name: client.name,
          description: description,
          url: client.url,
          logo_url: client.logo_url,
          app_type: client.app_type,
          callback_url: 'https://example.com/callback',
          login_url: 'https://example.com/login',
          logout_url: 'https://example.com/logout',
          allowed_origin: 'https://example.com',
        },
      }
    end
    let(:description) { 'セットリスト管理アプリ' }

    let(:auth0_client) { spy(:auth0_client) }

    before do
      allow(auth0_client).to receive(:patch_client).and_return({})
      allow(AppAuth0Client).to receive(:instance).and_return(auth0_client)

      log_in_as client.developer.user
    end

    it 'requests Auth0 to update client, updates client and redirects to /clients/:id/edit' do
      patch client_path(client), params: params

      expect(auth0_client).to have_received(:patch_client).with(client.auth0_id, instance_of(Hash))
      expect(client.reload.description).to eq description
      expect(response).to redirect_to edit_client_path(client)
    end

    context 'with invalid params' do
      let(:description) { 'a' * 141 }

      it 'responds 422' do
        patch client_path(client), params: params

        expect(auth0_client).not_to have_received(:patch_client)
        expect(client.reload.description).not_to eq description
        expect(response).to have_http_status :unprocessable_entity
      end
    end

    context 'when Auth0 responds 400' do
      before do
        allow(auth0_client).to receive(:patch_client).and_raise(Auth0::BadRequest, '{"message":"invalid"}')
      end

      it 'responds 422' do
        patch client_path(client), params: params

        expect(auth0_client).to have_received(:patch_client).with(client.auth0_id, instance_of(Hash))
        expect(client.reload.description).not_to eq description
        expect(response).to have_http_status :unprocessable_entity
      end
    end
  end
end
