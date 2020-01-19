require 'rails_helper'

RSpec.describe 'static_pages request:', type: :request do
  describe 'GET /' do
    before do
      create(:song)
    end

    it 'responds 200' do
      get root_path

      expect(response).to have_http_status(:ok)
    end
  end

  describe 'GET /privacy' do
    it 'responds 200' do
      get privacy_path
      expect(response).to have_http_status(:ok)
    end
  end
end
