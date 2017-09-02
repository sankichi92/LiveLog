require 'rails_helper'

RSpec.describe 'Api::V1::Profiles', type: :request do
  let(:user) { create(:user) }
  let(:token) { create(:token, user: user) }
  let(:headers) { authorized_headers(token) }

  describe 'GET /api/v1/profile' do
    let(:expected_body) do
      {
        id: user.id,
        first_name: user.first_name,
        last_name: user.last_name,
        email: user.email,
        joined: user.joined,
        public: user.public,
        nickname: user.nickname,
        url: user.url,
        intro: user.intro
      }
    end

    it 'responds with valid status and json' do
      get api_v1_profile_path, headers: headers
      expect(response).to have_http_status(200)
      expect(response.body).to be_json_as(expected_body)
    end
  end

  describe 'PUT /api/v1/profile' do
    let(:params) do
      {
        nickname: 'アンプラグダー',
        url: 'https://example.com/profile',
        intro: 'ギターを弾きます',
        public: true
      }
    end
    let(:expected_body) do
      {
        id: user.id,
        first_name: user.first_name,
        last_name: user.last_name,
        email: user.email,
        joined: user.joined,
        public: params[:public],
        nickname: params[:nickname],
        url: params[:url],
        intro: params[:intro]
      }
    end

    it 'responds with valid status and json' do
      put api_v1_profile_path, params: params, headers: headers

      expect(user.reload.nickname).to eq(params[:nickname])
      expect(user.reload.url).to eq(params[:url])
      expect(user.reload.intro).to eq(params[:intro])
      expect(user.reload.public).to eq(params[:public])

      expect(response).to have_http_status(200)
      expect(response.body).to be_json_as(expected_body)
    end
  end
end
