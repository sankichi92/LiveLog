# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'clients request:', type: :request do
  include Auth0ClientHelper

  describe 'GET /clients/new' do
    let(:user) { create(:user) }

    before do
      create(:developer, user:)
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

      it 'redirects to /settings/developer' do
        get new_client_path

        expect(response).to redirect_to developer_path
      end
    end

    context 'without github_access_token' do
      before do
        user.developer.update!(github_access_token: nil)
      end

      it 'redirects to /settings/developer' do
        get new_client_path

        expect(response).to redirect_to developer_path
      end
    end
  end

  describe 'POST /clients' do
    let(:developer) { create(:developer) }
    let(:params) do
      {
        client: {
          name:,
          app_type: 'regular_web',
        },
      }
    end
    let(:name) { 'LiveLog' }

    let(:octokit_client) { instance_double(Octokit::Client, user: { avatar_url: 'https://example.com/github_avatar_url' }) }
    let(:auth0_client) do
      double(:auth0_client).tap do |auth0_client|
        allow(auth0_client).to receive(:create_client).and_return({ 'client_id' => 'auth0_client_id' })
        allow(auth0_client).to receive(:create_client_grant).and_return({ 'id' => 'auth0_grant_id' })
      end
    end

    before do
      allow(Octokit::Client).to receive(:new).with(access_token: developer.github_access_token).and_return(octokit_client)
      allow(LiveLog::Auth0Client).to receive(:instance).and_return(auth0_client)

      log_in_as developer.user
    end

    it 'creates a client and redirects to /clients' do
      expect { post clients_path, params: }.to change(Client, :count).by(1)

      expect(response).to have_http_status :redirect
    end

    context 'with invalid params' do
      let(:name) { '' }

      it 'responds 422' do
        expect { post clients_path, params: }.not_to change(Client, :count)

        expect(response).to have_http_status :unprocessable_entity
      end
    end

    context 'when github_access_token has been revoked' do
      before do
        allow(octokit_client).to receive(:user).and_raise(Octokit::Unauthorized)
      end

      it 'redirects to /settings/developer' do
        expect { post clients_path, params: }.not_to change(Client, :count)

        expect(response).to redirect_to developer_path
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

      it 'redirects to /settings/developer' do
        get edit_client_path(client)

        expect(response).to redirect_to developer_path
      end
    end
  end

  describe 'PATCH /clients/:id' do
    let(:client) { create(:client) }
    let(:params) do
      {
        client: {
          name: client.name,
          description:,
          logo_url: client.logo_url,
          app_type: client.app_type,
          callback_url: 'https://example.com/callback',
          login_url: 'https://example.com/login',
          logout_url: 'https://example.com/logout',
          web_origin: 'https://example.com',
          jwt_signature_alg: 'RS256',
        },
      }
    end
    let(:description) { 'セットリスト管理アプリ' }

    let(:auth0_client) { spy(:auth0_client) }

    before do
      allow(auth0_client).to receive(:patch_client).and_return({})
      allow(LiveLog::Auth0Client).to receive(:instance).and_return(auth0_client)

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

  describe 'DELETE /clients/:id' do
    let(:client) { create(:client) }

    let(:auth0_client) { spy(:auth0_client) }

    before do
      allow(auth0_client).to receive(:delete_client)
      allow(LiveLog::Auth0Client).to receive(:instance).and_return(auth0_client)

      log_in_as client.developer.user
    end

    it 'destroys the client and redirects to /settings/developer' do
      delete client_path(client)

      expect(auth0_client).to have_received(:delete_client).with(client.auth0_id)
      expect { client.reload }.to raise_error(ActiveRecord::RecordNotFound)
      expect(response).to redirect_to developer_path
    end
  end
end
