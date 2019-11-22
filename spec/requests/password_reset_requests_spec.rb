require 'rails_helper'

RSpec.describe 'Password reset requests', type: :request do
  describe 'GET /password_resets/new' do
    it 'responds 200' do
      get new_password_reset_path
      expect(response).to have_http_status(:ok)
    end
  end

  describe 'POST /password_resets' do
    before { ActionMailer::Base.deliveries.clear }

    context 'with nonexistent email' do
      let(:user) { create(:user) }

      it 'responds 422' do
        post password_resets_path, params: { password_reset: { email: 'nonexistent@example.com' } }
        expect(user.reload.reset_digest).to be_blank
        expect(ActionMailer::Base.deliveries.size).to eq 0
        expect(response).to have_http_status(:unprocessable_entity)
      end
    end

    context 'with inactivated user' do
      let(:user) { create(:user, :inactivated) }

      it 'responds 422' do
        post password_resets_path, params: { password_reset: { email: user.email } }
        expect(user.reload.reset_digest).to be_blank
        expect(ActionMailer::Base.deliveries.size).to eq 0
        expect(response).to have_http_status(:unprocessable_entity)
      end
    end

    context 'with existent email for activated user' do
      let(:user) { create(:user) }

      it 'sets reset_digest, sends email and redirects to /' do
        post password_resets_path, params: { password_reset: { email: user.email } }
        expect(user.reload.reset_digest).to be_present
        expect(ActionMailer::Base.deliveries.size).to eq 1
        expect(response).to redirect_to(root_url)
      end
    end
  end

  describe 'GET /password_resets/edit' do
    let(:reset_sent_at) { 1.hour.ago }
    let(:token) { 'token' }
    let(:user) { create(:user, reset_digest: BCrypt::Password.create(token), reset_sent_at: reset_sent_at) }

    context 'without email' do
      it 'redirects to /' do
        get edit_password_reset_path(token)
        expect(response).to redirect_to(root_url)
      end
    end

    context 'with invalid token' do
      it 'redirects to /' do
        get edit_password_reset_path('invalid_token', email: user.email)
        expect(response).to redirect_to(root_url)
      end
    end

    context 'with expired token' do
      let(:reset_sent_at) { 3.hours.ago }

      it 'redirects to /password_resets/new' do
        get edit_password_reset_path(token, email: user.email)
        expect(response).to redirect_to(new_password_reset_url)
      end
    end

    context 'with valid token' do
      it 'responds 200' do
        get edit_password_reset_path(token, email: user.email)
        expect(response).to have_http_status(:ok)
      end
    end
  end

  describe 'PATCH /password_resets' do
    let(:token) { 'token' }
    let(:user) { create(:user, reset_digest: BCrypt::Password.create(token), reset_sent_at: 1.hour.ago) }

    context 'with empty password' do
      it 'responds 422' do
        patch password_reset_path(token), params: { email: user.email, user: { password: '', password_confirmation: '' } }

        expect(user.password_digest).to eq user.reload.password_digest
        expect(session[:user_id]).to be_nil
        expect(response).to have_http_status(:unprocessable_entity)
      end
    end

    context 'with invalid password' do
      it 'responds 422' do
        patch password_reset_path(token), params: { email: user.email, user: { password: 'new_password', password_confirmation: 'wrong_password' } }

        expect(user.password_digest).to eq user.reload.password_digest
        expect(session[:user_id]).to be_nil
        expect(response).to have_http_status(:unprocessable_entity)
      end
    end

    context 'with valid password' do
      it 'updates password, sets session and redirects to /users/:id' do
        patch password_reset_path(token), params: { email: user.email, user: { password: 'new_password', password_confirmation: 'new_password' } }

        expect(user.password_digest).not_to eq user.reload.password_digest
        expect(session[:user_id]).to eq user.id
        expect(response).to redirect_to(user.member)
      end
    end
  end
end
