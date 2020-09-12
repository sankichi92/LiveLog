# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'home request:', type: :request do
  describe 'GET /' do
    before do
      create(:song)
      create_list(:live, 5)
    end

    it 'responds 200' do
      get root_path

      expect(response).to have_http_status(:ok)
    end
  end
end
