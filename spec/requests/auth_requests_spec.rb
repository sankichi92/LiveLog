require 'rails_helper'

RSpec.describe 'Auth requests', type: :request do
  describe 'GET /auth/google_oauth2/callback' do
    let(:auth) { OmniAuth::AuthHash.new(Faker::Omniauth.google) }

    before do
      OmniAuth.config.mock_auth[:google_oauth2] = auth
    end

    context 'with logged-in user' do
      let(:user) { create(:user) }

      before do
        log_in_as(user, capybara: false)
      end

      it 'creates identity and redirects to /users/:id' do
        get auth_google_oauth2_callback_path

        expect(user.reload.identities.google_oauth2.take.uid).to eq auth.uid
        expect(user.google_credential.token).to eq auth.credentials.token
        expect(flash[:success]).to eq 'Google アカウントと紐付けました'
        expect(response).to redirect_to(user)
      end
    end

    context 'with non-logged-in user' do
      context 'who has google_oauth2 identity' do # rubocop:disable RSpec/ContextWording
        let!(:identity) { create(:identity, provider: 'google_oauth2', uid: auth.uid) }

        it 'make the user logged-in and redirects to /users/:id' do
          get auth_google_oauth2_callback_path

          expect(session[:user_id]).to eq identity.user.id
          expect(flash[:success]).to eq 'ログインしました'
          expect(response).to redirect_to(identity.user)
        end
      end

      context 'who does not have google_oauth2 identity' do # rubocop:disable RSpec/ContextWording
        it 'redirects to /login' do
          get auth_google_oauth2_callback_path

          expect(flash[:warning]).to eq '有効なアカウントが見つかりませんでした'
          expect(response).to redirect_to(login_url)
        end
      end
    end

    context 'with invalid credentials' do
      let(:auth) { :invalid_credentials }

      it 'redirects to /auth/failure' do
        get auth_google_oauth2_callback_path

        expect(response).to redirect_to(auth_failure_url(message: 'invalid_credentials', strategy: 'google_oauth2'))
      end
    end
  end

  describe 'DELETE /auth/google_oauth2' do
    context 'with logged-in user who has google oauth2 identity' do
      let(:user) { create(:user) }

      before do
        create(:identity, user: user, provider: 'google_oauth2')

        log_in_as user, capybara: false
      end

      it 'redirects to /login' do
        delete auth_google_oauth2_path

        expect(user.reload.identities.google_oauth2.take).to be_nil
        expect(flash[:success]).to eq 'Google アカウントとの紐付けを解除しました'
        expect(response).to redirect_to(user)
      end
    end

    context 'with non-logged-in user' do
      it 'redirects to /login' do
        delete auth_google_oauth2_path

        expect(response).to redirect_to(login_url)
      end
    end
  end

  describe 'GET /auth/failure' do
    let(:message) { 'error message' }
    let(:params) { { message: message, strategy: 'google_oauth2' } }

    it 'redirects to /login' do
      get auth_failure_path, params: params

      expect(response).to redirect_to(login_url)
    end
  end
end
