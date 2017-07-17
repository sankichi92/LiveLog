require 'rails_helper'

RSpec.describe 'Api::V1::Tokens', type: :request do

  describe 'POST /api/v1/login' do
    let!(:user) { create(:user) }

    context 'with valid email and password' do
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

      before do
        post api_v1_token_path, params: {
          email: user.email,
          password: user.password
        }
      end

      it 'responds with valid json' do
        expect(response).to have_http_status(201)
        expect(response.body).to be_json_as(expected_body)
      end
    end

    context 'with invalid email and password' do
      before do
        post api_v1_token_path, params: {
          email: 'invalid@example.com',
          password: 'invalid_password'
        }
      end

      it { expect(response).to have_http_status(401) }
    end
  end
end
