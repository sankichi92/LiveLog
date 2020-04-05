require 'rails_helper'

RSpec.describe 'no contents request:', type: :request do
  describe 'GET /api/' do
    let(:access_token) { stub_access_token(scope: 'read:public') }

    it 'responds 204' do
      get api_root_path, headers: { authorization: "Bearer #{access_token}" }

      expect(response).to have_http_status :no_content
    end
  end
end
