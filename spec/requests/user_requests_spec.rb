require 'rails_helper'

RSpec.describe 'User requests', type: :request do
  describe 'GET /members/:id/edit by correct user' do
    let(:user) { create(:user) }

    before do
      log_in_as(user, capybara: false)
    end

    it 'responds 200' do
      get edit_user_path(user)

      expect(response).to have_http_status :ok
    end
  end

  describe 'PATCH /members/:id by correct user' do
    let(:user) { create(:user, email: 'before@example.com') }

    before do
      log_in_as(user, capybara: false)
    end

    context 'with valid params' do
      let(:new_email) { 'after@example.com' }

      it 'updates the user and redirects to /members/:id' do
        patch user_path(user), params: { user: { email: new_email } }

        expect(response).to redirect_to edit_user_path(user)
        expect(user.reload.email).to eq new_email
      end
    end

    context 'with invalid params' do
      let(:invalid_email) { 'invalid' }

      it 'responds 422' do
        patch user_path(user), params: { user: { email: invalid_email } }

        expect(response).to have_http_status(:unprocessable_entity)
        expect(user.reload.email).not_to eq invalid_email
      end
    end
  end

  describe 'GET /members/:id/password/edit by correct user' do
    let(:user) { create(:user) }

    before { log_in_as(user, capybara: false) }

    it 'responds 200' do
      get edit_user_password_path(user)
      expect(response).to have_http_status(:ok)
    end
  end

  describe 'PATCH /members/:id/password by correct user' do
    let(:user) { create(:user) }

    before { log_in_as(user, capybara: false) }

    context 'with valid params' do
      let(:new_password_attrs) { { password: 'new_password' } }

      it 'updates the user and redirects to /members/:id' do
        patch user_password_path(user), params: { current_password: user.password, user: new_password_attrs }

        expect(response).to redirect_to user.member
        expect(user.password_digest).not_to eq user.reload.password_digest
      end
    end

    context 'with invalid params' do
      let(:new_password_attrs) { { password: '1234' } }

      it 'responds 422' do
        patch user_password_path(user), params: { current_password: user.password, user: new_password_attrs }

        expect(response).to have_http_status(:unprocessable_entity)
        expect(user.password_digest).to eq user.reload.password_digest
      end
    end
  end

  describe 'POST /members/:id/admin by admin user' do
    let(:user) { create(:user) }

    before { log_in_as(create(:admin), capybara: false) }

    it 'make the user admin and redirects to /users/:id' do
      post user_admin_path(user)
      expect(user.reload.admin).to be true
      expect(response).to redirect_to(user)
    end
  end

  describe 'DELETE /members/:id/admin by admin user' do
    let(:user) { create(:admin) }

    before { log_in_as(create(:admin), capybara: false) }

    it 'make the user non-admin and redirects to /users/:id' do
      delete user_admin_path(user)
      expect(user.reload.admin).to be false
      expect(response).to redirect_to(user)
    end
  end
end
