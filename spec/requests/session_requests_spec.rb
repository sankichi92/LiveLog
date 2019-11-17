require 'rails_helper'

RSpec.describe 'Session requests', type: :request do
  describe 'GET /login' do
    it 'responds 200' do
      get login_path
      expect(response).to have_http_status(:ok)
    end
  end

  describe 'POST /login' do
    let(:user) { create(:user) }
    let(:email) { user.email }
    let(:password) { user.password }
    let(:remember_me) { '0' }
    let(:params) do
      {
        session: {
          email: email,
          password: password,
          remember_me: remember_me,
        },
      }
    end

    context 'with invalid email' do
      let(:email) { 'invalid@example.com' }

      it 'responds 422' do
        post login_path, params: params
        expect(response).to have_http_status(:unprocessable_entity)
      end
    end

    context 'with invalid password' do
      let(:password) { 'invalid password' }

      it 'responds 422' do
        post login_path, params: params
        expect(response).to have_http_status(:unprocessable_entity)
      end
    end

    context 'when user is not activated' do
      let(:email) { 'invited@example.com' }
      let(:user) { create(:user, :inactivated, email: email) }

      it 'responds 422' do
        post login_path, params: params
        expect(response).to have_http_status(:unprocessable_entity)
      end
    end

    context 'with valid information and when user is activated' do
      it 'saves user_id in session and redirects to /members/:id' do
        post login_path, params: params

        expect(session[:user_id]).to eq user.id
        expect(response).to redirect_to(user.member)
      end
    end

    context "with remember_me = '1'" do
      let(:remember_me) { '1' }

      it "update user's remember_digest and save remember_token in cookies" do
        post login_path, params: params
        expect(user.reload.remember_digest).to be_present
        expect(cookies[:user_id]).to be_present
        expect(cookies[:remember_token]).to be_present
      end
    end
  end

  describe 'DELETE /logout' do
    let(:user) { create(:user) }

    before { log_in_as(user, capybara: false, remember_me: '1') }

    it 'deletes session and cookies' do
      delete logout_path
      expect(session[:user_id]).to be_nil
      expect(cookies[:user_id]).to be_blank
      expect(cookies[:remember_token]).to be_blank
    end
  end
end
