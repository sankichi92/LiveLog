require 'rails_helper'

RSpec.describe 'Static pages requests', type: :request do
  describe 'GET /' do
    it 'responds 200' do
      get root_path
      expect(response).to have_http_status(:ok)
    end
  end

  describe 'GET /donation' do
    context 'with non-logged-in user' do
      it 'redirects to /login' do
        get donation_path
        expect(response).to redirect_to(login_url)
      end
    end

    context 'with logged-in user' do
      before { log_in_as(create(:user), capybara: false) }

      it 'responds 200' do
        get donation_path
        expect(response).to have_http_status(:ok)
      end
    end
  end

  describe 'GET /privacy' do
    it 'responds 200' do
      get privacy_path
      expect(response).to have_http_status(:ok)
    end
  end
end
