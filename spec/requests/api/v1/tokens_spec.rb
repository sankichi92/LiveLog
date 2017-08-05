require 'rails_helper'

RSpec.describe 'Api::V1::Tokens', type: :request do

  describe 'POST /api/v1/login' do
    let!(:user) { create(:user) }

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
            email: user.email,
            joined: user.joined,
            name: user.full_name
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
end
