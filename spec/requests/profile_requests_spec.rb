require 'rails_helper'
require 'app_auth0_client'

RSpec.describe 'Profile requests:', type: :request do
  describe 'GET /settings/profile' do
    let(:user) { create(:user) }

    before do
      log_in_as user
    end

    it 'responds 200' do
      get profile_path

      expect(response).to have_http_status(:ok)
    end
  end

  describe 'PATCH /settings/profile' do
    let(:member) { create(:member, name: 'ギータ', url: nil, bio: nil, avatar: nil) }
    let(:user) { create(:user, member: member) }

    before do
      log_in_as user
    end

    context 'with valid params including current name' do
      let(:params) do
        {
          member: {
            name: 'ギータ',
            url: 'https://example.com/profile',
            bio: 'ギターを弾きます',
            avatar: Rack::Test::UploadedFile.new("#{::Rails.root}/spec/fixtures/files/avatar.png", 'image/png'),
          },
        }
      end

      it "updates the logged-in user's profile and redirects to their profile" do
        patch profile_path, params: params

        expect(response).to redirect_to user.member
        expect(member.reload.url).to eq 'https://example.com/profile'
        expect(member.bio).to eq 'ギターを弾きます'
        expect(member.avatar).to be_attached
      end
    end

    context 'with valid params including new name' do
      let(:params) do
        {
          member: {
            name: 'ベス',
            url: '',
            bio: 'ベースに転向しました',
          },
        }
      end
      let(:auth0_client) { spy(:app_auth0_client) }

      before do
        allow(AppAuth0Client).to receive(:instance).and_return(auth0_client)
      end

      it "updates the logged-in user's profile, requests to update Auth0 user and redirect to their profile" do
        patch profile_path, params: params

        expect(response).to redirect_to user.member
        expect(member.reload.name).to eq 'ベス'
        expect(member.bio).to eq 'ベースに転向しました'
        expect(auth0_client).to have_received(:patch_user).with(user.auth0_id, name: 'ベス')
      end
    end

    context 'with invalid params' do
      let(:params) do
        { member: { name: '' } }
      end

      it 'responds 422' do
        patch profile_path, params: params

        expect(response).to have_http_status :unprocessable_entity
        expect(member.reload.name).not_to eq ''
      end
    end
  end
end
