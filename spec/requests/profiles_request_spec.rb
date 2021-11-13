# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'profiles request:', type: :request do
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
    let(:member) { create(:member, name: 'ギータ', url: nil, bio: nil) }
    let(:user) { create(:user, member: member) }

    let(:params) do
      {
        member: {
          name: 'ギータ',
          url: 'https://example.com/profile',
          bio: 'ギターを弾きます',
        },
      }
    end

    before do
      log_in_as user
    end

    it "updates the logged-in user's profile and redirects to their profile" do
      patch profile_path, params: params

      expect(member.reload.url).to eq 'https://example.com/profile'
      expect(member.bio).to eq 'ギターを弾きます'
      expect(response).to redirect_to user.member
    end

    context 'with avatar' do
      let(:params) do
        {
          avatar: Rack::Test::UploadedFile.new("#{::Rails.root}/spec/fixtures/files/avatar.png", 'image/png'),
          member: {
            name: 'ギータ',
          },
        }
      end
      let(:cloudinary_uploader) { class_spy(Cloudinary::Uploader).as_stubbed_const }
      let(:auth0_client) { spy(:app_auth0_client) }

      before do
        allow(cloudinary_uploader).to receive(:upload) do |_file, options|
          { 'public_id' => options[:public_id], 'version' => Time.zone.now.to_i }
        end
        allow(LiveLog::Auth0Client).to receive(:instance).and_return(auth0_client)
      end

      it "updates the logged-in user's profile, uploads avatar to Cloudinary and redirects to their profile" do
        patch profile_path, params: params

        expect(cloudinary_uploader).to have_received(:upload).with(anything, hash_including(public_id: member.id))
        expect(member.avatar).to be_persisted
        expect(auth0_client).to have_received(:patch_user).with(user.auth0_id, name: 'ギータ', picture: String).once
        expect(response).to redirect_to user.member
      end
    end

    context 'with new name' do
      let(:params) do
        {
          member: {
            name: 'ベス',
            bio: 'ベースに転向しました',
          },
        }
      end
      let(:auth0_client) { spy(:app_auth0_client) }

      before do
        allow(LiveLog::Auth0Client).to receive(:instance).and_return(auth0_client)
      end

      it "updates the logged-in user's profile, requests to update Auth0 user and redirect to their profile" do
        patch profile_path, params: params

        expect(member.reload.name).to eq 'ベス'
        expect(member.bio).to eq 'ベースに転向しました'
        expect(auth0_client).to have_received(:patch_user).with(user.auth0_id, name: 'ベス').once
        expect(response).to redirect_to user.member
      end
    end

    context 'with invalid params' do
      let(:params) do
        { member: { name: '' } }
      end

      it 'responds 422' do
        patch profile_path, params: params

        expect(member.reload.name).not_to eq ''
        expect(response).to have_http_status :unprocessable_entity
      end
    end
  end
end
