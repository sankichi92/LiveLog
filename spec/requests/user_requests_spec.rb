require 'rails_helper'
require 'app_auth0_client'

RSpec.describe 'User requests', type: :request do
  describe 'GET /members/:member_id/user/new' do
    let(:member) { create(:member) }

    before do
      log_in_as create(:user)
    end

    context 'when there is no activated user associated with the given member' do
      it 'responds 200' do
        get new_member_user_path(member)

        expect(response).to have_http_status :ok
      end
    end

    context 'when an activated user associated with the given member exists' do
      before do
        create(:user, member: member)
      end

      it 'redirects to /members/:id with alert' do
        get new_member_user_path(member)

        expect(response).to redirect_to member
        expect(flash.alert).to eq 'すでにユーザー登録が完了しています'
      end
    end
  end

  describe 'POST /members/:member_id/user' do
    let(:member) { create(:member) }
    let(:email) { 'new@example.com' }

    let(:auth0_client) { spy(:app_auth0_client) }

    before do
      allow(AppAuth0Client).to receive(:instance).and_return(auth0_client)

      log_in_as create(:user)
    end

    context 'when there is no user associated with the given member' do
      it 'creates a user, requests to create Auth0 user and change their password' do
        post member_user_path(member), params: { email: email }

        expect(response).to redirect_to member
        expect(flash.notice).to eq '招待しました'
        expect(member.reload.user).to be_persisted
        expect(auth0_client).to have_received(:create_user).with(anything, hash_including(email: email)).once
        expect(auth0_client).not_to have_received(:patch_user)
        expect(auth0_client).to have_received(:change_password).with(email, nil).once
      end
    end

    context 'when an inactivated user exists and the email is different from Auth0 user' do
      let(:user) { create(:user, :inactivated, member: member) }

      before do
        allow(auth0_client).to receive(:user).with(user.auth0_id).and_return('email' => 'previous@example.com')
      end

      it 'requests to update Auth0 user and change their password, and redirects to /members/:id' do
        post member_user_path(member), params: { email: email }

        expect(response).to redirect_to member
        expect(flash.notice).to eq '招待しました'
        expect(auth0_client).not_to have_received(:create_user)
        expect(auth0_client).to have_received(:patch_user).with(user.auth0_id, hash_including(email: email)).once
        expect(auth0_client).to have_received(:change_password).with(email, nil).once
      end
    end

    context 'when an inactivated user exists and the email is the same as Auth0 user' do
      let(:user) { create(:user, :inactivated, member: member) }

      before do
        allow(auth0_client).to receive(:user).with(user.auth0_id).and_return('email' => email)
      end

      it 'requests to change Auth0 user password, and redirects to /members/:id' do
        post member_user_path(member), params: { email: email }

        expect(response).to redirect_to member
        expect(flash.notice).to eq '招待しました'
        expect(auth0_client).not_to have_received(:create_user)
        expect(auth0_client).not_to have_received(:patch_user)
        expect(auth0_client).to have_received(:change_password).with(email, nil).once
      end
    end


    context 'when Auth0 responds bad_request' do
      before do
        allow(auth0_client).to receive(:create_user).and_raise(Auth0::BadRequest, '400')
      end

      it 'does not create user and responds 422' do
        expect { post member_user_path(member), params: { email: email } }.not_to change(User, :count)

        expect(response).to have_http_status(:unprocessable_entity)
        expect(auth0_client).not_to have_received(:change_password)
      end
    end

    context 'when an activated user associated with the given member exists' do
      let(:email) { 'new@example.com' }

      before do
        create(:user, member: member)
      end

      it 'redirects to /members/:id with alert' do
        post member_user_path(member), params: { email: email }

        expect(response).to redirect_to member
        expect(flash.alert).to eq 'すでにユーザー登録が完了しています'
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

    xcontext 'with invalid params' do
      let(:invalid_email) { 'invalid' }

      it 'responds 422' do
        patch user_path(user), params: { user: { email: invalid_email } }

        expect(response).to have_http_status(:unprocessable_entity)
        expect(user.reload.email).not_to eq invalid_email
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
