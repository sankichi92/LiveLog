# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'docs request:' do
  describe 'GET /privacy' do
    it 'responds 200' do
      get privacy_path

      expect(response).to have_http_status(:ok)
    end
  end
end
