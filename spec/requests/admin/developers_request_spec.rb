# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'admin/admins request:' do
  let(:admin) { create(:admin) }

  before do
    log_in_as admin.user
  end

  describe 'GET /admin/developers' do
    before do
      create_pair(:developer).each do |developer|
        create_pair(:client, developer:)
      end
    end

    it 'responds 200' do
      get admin_developers_path

      expect(response).to have_http_status :ok
    end
  end
end
