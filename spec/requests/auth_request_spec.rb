# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'auth request:', type: :request do
  describe 'GET /auth/auth0/callback' do
    let(:user) { create(:user, :inactivated) }

    context 'with valid auth' do
      before do
        OmniAuth.config.mock_auth[:auth0] = OmniAuth::AuthHash.new(
          provider: 'auth0',
          uid: user.auth0_id,
          credentials: {
            token: 'access_token',
            expires_at: 1.day.from_now.to_i,
            refresh_token: 'refresh_token',
          },
          extra: {
            raw_info: {
              name: user.member.name,
              email: user.email,
              email_verified: true,
            },
          },
        )
      end

      it 'makes the user logged-in and redirects to / with notice' do
        get auth_auth0_callback_path

        expect(response).to redirect_to root_path
        expect(flash.notice).to eq 'ログインしました'
        expect(session[:user_id]).to eq user.id
        expect(user.reload).to be_activated
      end
    end

    context 'with valid auth, but user is not found' do
      before do
        OmniAuth.config.mock_auth[:auth0] = OmniAuth::AuthHash.new(
          provider: 'auth0',
          uid: 'auth0|0',
        )
      end

      it 'redirects to / with alert' do
        get auth_auth0_callback_path

        expect(response).to redirect_to root_path
        expect(flash.alert).to include 'ログインに失敗しました'
        expect(session[:user_id]).to be_nil
      end
    end

    context 'with invalid auth' do
      before do
        OmniAuth.config.mock_auth[:auth0] = :invalid_credentials
      end

      it 'redirects to /auth/failure' do
        get auth_auth0_callback_path

        expect(response).to have_http_status :redirect
      end
    end
  end

  describe 'GET /auth/github/callback' do
    let(:github_username) { 'sankichi92' }

    before do
      OmniAuth.config.mock_auth[:github] = OmniAuth::AuthHash.new(Faker::Omniauth.github(name: github_username))
    end

    context 'with current_user' do
      let(:user) { create(:user) }

      before do
        log_in_as user
      end

      it 'creates a developer and redirects to /clients' do
        get auth_github_callback_path

        expect(user.reload.developer).to be_persisted
        expect(user.developer.github_username).to eq github_username
        expect(response).to redirect_to developer_path
      end
    end

    context 'without current_user' do
      it 'redirects to /' do
        expect { get auth_github_callback_path }.not_to change(Developer, :count)

        expect(response).to redirect_to root_path
      end
    end

    context 'with invalid auth' do
      before do
        OmniAuth.config.mock_auth[:github] = :invalid_credentials
      end

      it 'redirects to /auth/failure' do
        get auth_github_callback_path

        expect(response).to have_http_status :redirect
      end
    end
  end

  describe 'DELETE /logout' do
    let(:user) { create(:user) }

    let(:auth0_client) { double(:auth0_client, logout_url: 'logout_url') }

    before do
      allow(AppAuth0Client).to receive(:instance).and_return(auth0_client)

      log_in_as(user)
    end

    it 'resets session and redirects with notice' do
      delete logout_path

      expect(session[:user_id]).to be_nil
      expect(flash.notice).to eq 'ログアウトしました'
      expect(auth0_client).to have_received(:logout_url).with(root_url, anything)
      expect(response).to have_http_status :redirect
    end
  end
end
