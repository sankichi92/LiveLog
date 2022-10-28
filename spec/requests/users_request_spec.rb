# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'users request' do
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
        create(:user, member:)
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
    let(:params) do
      {
        user: {
          email:,
        },
      }
    end
    let(:email) { 'new@example.com' }

    let(:auth0_client) { spy(:app_auth0_client) }

    before do
      allow(LiveLog::Auth0Client).to receive(:instance).and_return(auth0_client)

      log_in_as create(:user)
    end

    context 'when there is no user associated with the given member' do
      before do
        allow(auth0_client).to receive(:user).and_raise(Auth0::NotFound.new('The user does not exist.'))
        allow(auth0_client).to receive(:create_user).and_return('email' => email)
      end

      it 'creates a user, requests to create Auth0 user and change their password' do
        post member_user_path(member), params: params

        expect(member.reload.user).to be_persisted
        expect(auth0_client).to have_received(:create_user).with(anything, hash_including(email:)).once
        expect(auth0_client).to have_received(:change_password).with(email, nil).once
        expect(response).to redirect_to member
        expect(flash.notice).to eq '招待しました'
      end
    end

    context 'when an inactivated user exists' do
      let(:user) { create(:user, :inactivated, member:) }

      before do
        allow(auth0_client).to receive(:user).with(user.auth0_id, anything).and_return('email' => email)
      end

      it 'requests to update Auth0 user and change their password, and redirects to /members/:id' do
        post member_user_path(member), params: params

        expect(auth0_client).to have_received(:change_password).with(email, nil).once
        expect(response).to redirect_to member
        expect(flash.notice).to eq '招待しました'
      end
    end

    context 'with invalid email' do
      let(:email) { 'invalid' }

      it 'does not create user and responds 422' do
        post member_user_path(member), params: params

        expect(member.reload.user).to be_nil
        expect(auth0_client).not_to have_received(:change_password)
        expect(response).to have_http_status(:unprocessable_entity)
      end
    end

    context 'when an activated user associated with the given member exists' do
      let(:email) { 'new@example.com' }

      before do
        create(:user, member:)
      end

      it 'redirects to /members/:id with alert' do
        post member_user_path(member), params: params

        expect(response).to redirect_to member
        expect(flash.alert).to eq 'すでにユーザー登録が完了しています'
      end
    end
  end
end
