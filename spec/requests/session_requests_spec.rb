require 'rails_helper'

RSpec.describe 'Session requests:', type: :request do
  describe 'GET /auth/auth0/callback' do
    let(:user) { create(:user, :inactivated) }

    context 'with valid auth' do
      before do
        OmniAuth.config.mock_auth[:auth0] = OmniAuth::AuthHash.new(
          provider: 'auth0',
          uid: user.auth0_id,
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

  describe 'DELETE /logout' do
    let(:user) { create(:user) }

    before { log_in_as(user) }

    it 'resets session and redirects with notice' do
      delete logout_path

      expect(response).to have_http_status :redirect
      expect(flash.notice).to eq 'ログアウトしました'
      expect(session[:user_id]).to be_nil
    end
  end
end
