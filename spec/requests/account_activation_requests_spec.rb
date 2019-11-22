require 'rails_helper'

RSpec.describe 'Account activation requests', type: :request do
  describe 'GET /users/:user_id/activation/new by logged-in user' do
    before do
      log_in_as create(:user)
    end

    context 'with inactivated user' do
      let(:user) { create(:user, :inactivated) }

      it 'responds 200' do
        get new_user_activation_path(user)

        expect(response).to have_http_status(:ok)
      end
    end

    context 'with activated user' do
      let(:user) { create(:user) }

      it 'redirects /users/:id' do
        get new_user_activation_path(user)

        expect(response).to redirect_to(user)
      end
    end
  end

  describe 'POST /users/:user_id/activation by logged-in user' do
    let(:user) { create(:user, :inactivated) }

    before do
      ActionMailer::Base.deliveries.clear
      log_in_as create(:user)
    end

    context 'with valid email' do
      let(:email) { 'invited@example.com' }

      it 'sends invitation email and redirects to /users/:id' do
        post user_activation_path(user), params: { user: { email: email } }

        expect(user.reload.email).to eq email
        expect(user.activation_digest).to be_present
        expect(ActionMailer::Base.deliveries.size).to eq 1
        expect(response).to redirect_to user.member
      end
    end

    context 'with invalid email' do
      let(:email) { 'invalid email' }

      it 'responds 422' do
        post user_activation_path(user), params: { user: { email: email } }

        expect(user.reload.email).not_to eq email
        expect(user.activation_digest).to be_blank
        expect(ActionMailer::Base.deliveries.size).to eq 0
        expect(response).to have_http_status(:unprocessable_entity)
      end
    end
  end

  describe 'GET /users/:user_id/activation/edit' do
    let(:token) { 'token' }
    let(:user) { create(:user, :inactivated, email: 'invited@example.com', activation_digest: BCrypt::Password.create(token)) }

    context 'with valid token' do
      it 'responds 200' do
        get edit_user_activation_path(user, t: token)

        expect(response).to have_http_status(:ok)
      end
    end

    context 'with invalid token' do
      it 'redirects to /' do
        get edit_user_activation_path(user, t: 'invalid_token')

        expect(response).to redirect_to(root_url)
      end
    end
  end

  describe 'PATCH /users/:user_id/activation' do
    let(:token) { 'token' }
    let(:user) { create(:user, :inactivated, email: 'invited@example.com', activation_digest: BCrypt::Password.create(token)) }

    context 'with valid password' do
      let(:password) { 'new_password' }

      # TODO
      before do
        instance_double(Member).tap do |m|
          allow(m).to receive(:update!)
          allow(Member).to receive(:find).with(user.id).and_return(m)
        end
      end

      it 'activates user, sets session and redirects to /users/:id' do
        patch user_activation_path(user), params: { t: token, user: { password: password, password_confirmation: password } }

        expect(user.password_digest).not_to eq user.reload.password_digest
        expect(user.activated).to be true
        expect(user.activated_at).to be_present
        expect(session[:user_id]).to eq user.id
        expect(response).to redirect_to user.member
      end
    end

    context 'with empty password' do
      let(:password) { '' }

      it 'responds 422' do
        patch user_activation_path(user), params: { t: token, user: { password: password, password_confirmation: password } }

        expect(user.password_digest).to eq user.reload.password_digest
        expect(user.activated).to be false
        expect(user.activated_at).to be_blank
        expect(session[:user_id]).to be_nil
        expect(response).to have_http_status(:unprocessable_entity)
      end
    end

    context 'with invalid password' do
      it 'responds 422' do
        patch user_activation_path(user), params: { t: token, user: { password: 'new_password', password_confirmation: 'wrong_password' } }

        expect(user.password_digest).to eq user.reload.password_digest
        expect(user.activated).to be false
        expect(user.activated_at).to be_blank
        expect(session[:user_id]).to be_nil
        expect(response).to have_http_status(:unprocessable_entity)
      end
    end
  end

  describe 'DELETE /users/:user_id/activation by admin user' do
    let(:user) { create(:user) }

    before { log_in_as(create(:admin)) }

    it 'deactivates the user and redirects to /users/:id' do
      delete user_activation_path(user)

      expect(user.reload.activated).to be false
      expect(user.activated_at).to be_nil
      expect(user.activation_digest).to be_nil
      expect(response).to redirect_to user.member
    end
  end
end
