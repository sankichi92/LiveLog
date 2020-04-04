require 'rails_helper'

RSpec.describe 'emails request:', type: :request do
  include Auth0UserHelper

  describe 'GET /settings/email' do
    let(:user) { create(:user) }

    before do
      stub_auth0_user(user)
      log_in_as user
    end

    it 'responds 200' do
      get email_path

      expect(response).to have_http_status(:ok)
    end
  end

  describe 'PATCH /settings/email' do
    let(:user) { create(:user) }
    let(:auth0_client) { spy(:app_auth0_client) }

    before do
      allow(auth0_client).to receive(:user).with(user.auth0_id, anything).and_return(
        'user_id' => user.auth0_id,
        'email' => 'current@example.com',
        'email_verified' => true,
      )
      allow(AppAuth0Client).to receive(:instance).and_return(auth0_client)
      log_in_as user
    end

    context 'with new email' do
      let(:email) { 'new@example.com' }

      it 'requests to update Auth0 user and redirects /settings/email' do
        patch email_path, params: { email: email, accept: '1' }

        expect(auth0_client).to have_received(:patch_user)
                                  .with(user.auth0_id, email: email, verify_email: true, user_metadata: { livelog_email_notifications: true }).once
        expect(flash.notice).to eq '確認メールを送信しました'
        expect(response).to redirect_to email_path
      end
    end

    context 'with current email' do
      let(:email) { 'current@example.com' }

      it 'requests to update Auth0 user and redirects /settings/email' do
        patch email_path, params: { email: email, accept: '0' }

        expect(auth0_client).to have_received(:patch_user).with(user.auth0_id, user_metadata: { livelog_email_notifications: false }).once
        expect(flash.notice).to eq '更新しました'
        expect(response).to redirect_to email_path
      end
    end

    context 'when Auth0 responds bad_request' do
      let(:email) { 'new@example.com' }

      before do
        allow(auth0_client).to receive(:patch_user).and_raise(Auth0::BadRequest, '400')
      end

      it 'responds 422' do
        patch email_path, params: { email: email, accept: '1' }

        expect(response).to have_http_status :unprocessable_entity
      end
    end
  end
end
