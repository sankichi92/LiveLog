# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'donations request:', type: :request do
  describe 'GET /donate' do
    before do
      create_list(:donation, 3)
      log_in_as create(:user)
    end

    it 'responds 200' do
      get donate_path

      expect(response).to have_http_status :ok
    end
  end
end
