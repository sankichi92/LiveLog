require 'rails_helper'

RSpec.describe 'User requests', type: :request do
  describe 'GET /members/:member_id/user/new' do
    let(:member) { create(:member) }

    before do
      create(:invitation, member: member)
    end

    context 'with the valid token' do
      let(:token) { member.invitation.token }

      it 'responds 200' do
        get new_member_user_path(member, token: token)

        expect(response).to have_http_status :ok
      end
    end

    context 'with an invalid token' do
      let(:token) { 'invalid' }

      it 'redirects to / with alert' do
        get new_member_user_path(member, token: token)

        expect(response).to redirect_to root_path
        expect(flash[:danger]).to eq '無効な URL です'
      end
    end

    context 'when a user associated with the member exists' do
      let(:token) { member.invitation.token }

      before do
        create(:user, member: member)
      end

      it 'redirects to / with alert' do
        get new_member_user_path(member, token: 'token')

        expect(response).to redirect_to root_path
        expect(flash[:danger]).to eq 'すでにユーザー登録が完了しています'
      end
    end
  end

  describe 'POST /members/:member_id/user/new' do
    let(:member) { create(:member) }

    before do
      create(:invitation, member: member)
    end

    context 'with a valid password' do
      let(:params) do
        {
          token: member.invitation.token,
          user: {
            password: 'password',
            password_confirmation: 'password',
          },
        }
      end

      it 'creates a user, logs-in as them and redirects to / with a notice' do
        post member_user_path(member), params: params

        expect(member.reload.user).to be_persisted
        expect(session[:user_id]).to eq member.user.id
        expect(response).to redirect_to root_path
      end
    end

    context 'with an invalid password' do
      let(:params) do
        {
          token: member.invitation.token,
          user: {
            password: 'password',
            password_confirmation: 'wront_password',
          },
        }
      end

      it 'responds 422' do
        post member_user_path(member), params: params

        expect(member.reload_user).to be_nil
        expect(session[:user_id]).to be_nil
        expect(response).to have_http_status :unprocessable_entity
      end
    end

    context 'with an invalid token' do
      let(:params) do
        {
          token: 'invalid',
          user: {
            password: 'password',
            password_confirmation: 'password',
          },
        }
      end

      it 'redirects to / with alert' do
        post member_user_path(member), params: params

        expect(response).to redirect_to root_path
        expect(flash[:danger]).to eq '無効な URL です'
      end
    end

    context 'when a user associated with the member exists' do
      let(:params) do
        {
          token: 'invalid',
          user: {
            password: 'password',
            password_confirmation: 'password',
          },
        }
      end

      before do
        create(:user, member: member)
      end

      it 'redirects to / with alert' do
        post member_user_path(member), params: params

        expect(response).to redirect_to root_path
        expect(flash[:danger]).to eq 'すでにユーザー登録が完了しています'
      end
    end
  end

  describe 'GET /members/:id/edit by correct user' do
    let(:user) { create(:user) }

    before do
      log_in_as(user)
    end

    it 'responds 200' do
      get edit_user_path(user)

      expect(response).to have_http_status :ok
    end
  end

  describe 'PATCH /members/:id by correct user' do
    let(:user) { create(:user, email: 'before@example.com') }

    before do
      log_in_as(user)
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

    before { log_in_as(user) }

    it 'responds 200' do
      get edit_user_password_path(user)
      expect(response).to have_http_status(:ok)
    end
  end

  describe 'PATCH /members/:id/password by correct user' do
    let(:user) { create(:user) }

    before { log_in_as(user) }

    context 'with valid params' do
      let(:new_password_attrs) { { password: 'new_password', password_confirmation: 'new_password' } }

      it 'updates the user and redirects to /members/:id' do
        patch user_password_path(user), params: { current_password: user.password, user: new_password_attrs }

        expect(response).to redirect_to user.member
        expect(user.password_digest).not_to eq user.reload.password_digest
      end
    end

    context 'with invalid params' do
      let(:new_password_attrs) { { password: 'new_password', password_confirmation: 'wrong_password' } }

      it 'responds 422' do
        patch user_password_path(user), params: { current_password: user.password, user: new_password_attrs }

        expect(response).to have_http_status(:unprocessable_entity)
        expect(user.password_digest).to eq user.reload.password_digest
      end
    end
  end

  describe 'POST /members/:id/admin by admin user' do
    let(:user) { create(:user) }

    before { log_in_as(create(:admin)) }

    it 'make the user admin and redirects to /users/:id' do
      post user_admin_path(user)
      expect(user.reload.admin).to be true
      expect(response).to redirect_to(user)
    end
  end

  describe 'DELETE /members/:id/admin by admin user' do
    let(:user) { create(:admin) }

    before { log_in_as(create(:admin)) }

    it 'make the user non-admin and redirects to /users/:id' do
      delete user_admin_path(user)
      expect(user.reload.admin).to be false
      expect(response).to redirect_to(user)
    end
  end
end
