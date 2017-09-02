require 'rails_helper'

RSpec.describe 'Api::V1::Tokens', type: :request do

  let!(:user) { create(:user) }

  describe 'POST /api/v1/login' do

    before do
      post api_v1_login_path, params: {
        email: email,
        password: password
      }
    end

    context 'with valid email and password' do
      let(:email) { user.email }
      let(:password) { user.password }
      let(:expected_body) do
        {
          token: String,
          user: {
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
        }
      end

      it 'responds with valid status and json' do
        expect(response).to have_http_status(201)
        expect(response.body).to be_json_as(expected_body)
      end
    end

    context 'with invalid email and password' do
      let(:email) { 'invalid@example.com' }
      let(:password) { 'invalid_password' }

      it { expect(response).to have_http_status(401) }
    end
  end

  describe 'DELETE /api/v1/logout' do

    before do
      delete api_v1_logout_path, headers: headers
    end

    context 'with no token' do
      let(:headers) { nil }
      it { expect(response).to have_http_status(401) }
    end

    context 'with invalid token' do
      let(:invalid_token) { create(:token) }
      let(:headers) do
        { Authorization: "Token token=\"#{invalid_token.token}\", id=\"#{user.id}\"" }
      end

      it { expect(response).to have_http_status(401) }
    end

    context 'with valid token' do
      let(:token) { create(:token, user: user) }
      let(:headers) do
        { Authorization: "Token token=\"#{token.token}\", id=\"#{user.id}\"" }
      end

      it 'responds with valid status and make api token invalid' do
        expect(response).to have_http_status(204)
        expect(token.user.valid_token?(token.token)).to be_falsey
      end
    end
  end
end
