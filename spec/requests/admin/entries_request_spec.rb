require 'rails_helper'

RSpec.describe 'admin/songs request:', type: :request do
  let(:admin) { create(:admin) }

  before do
    log_in_as admin
  end

  describe '/admin/entries' do
    before do
      create_list(:entry, 3)
    end

    context 'without playable_time' do
      it 'responds 200' do
        get admin_entries_path

        expect(response).to have_http_status :ok
      end
    end

    context 'with playable_time' do
      it 'responds 200' do
        get admin_entries_path(playable_time: Time.zone.now.iso8601)

        expect(response).to have_http_status :ok
      end
    end
  end
end
