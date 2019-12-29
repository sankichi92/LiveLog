require 'rails_helper'

RSpec.describe 'admin/lives request:', type: :request do
  let(:admin) { create(:admin) }

  before do
    log_in_as admin
  end

  describe 'GET /admin/lives' do
    before do
      create_pair(:live)
      create_pair(:live, :draft)
    end

    it 'responds 200' do
      get admin_lives_path

      expect(response).to have_http_status :ok
    end
  end
end
