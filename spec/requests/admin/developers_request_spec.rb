require 'rails_helper'

RSpec.describe 'admin/admins request:', type: :request do
  let(:admin) { create(:admin) }

  before do
    log_in_as admin.user
  end

  describe 'GET /admin/developers' do
    before do
      create_pair(:developer)
    end

    it 'responds 200' do
      get admin_developers_path

      expect(response).to have_http_status :ok
    end
  end
end
