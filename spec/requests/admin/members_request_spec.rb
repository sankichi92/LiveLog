require 'rails_helper'

RSpec.describe 'admin/members requests:', type: :request do
  let(:admin) { create(:admin) }

  before do
    log_in_as admin
  end

  describe 'GET /admin/members' do
    before do
      create_pair(:member)
      create_pair(:member, :with_user)
    end

    it 'responds 200' do
      get admin_members_path

      expect(response).to have_http_status :ok
    end
  end
end
