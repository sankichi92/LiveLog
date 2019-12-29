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

  describe 'GET /admin/lives/new' do
    it 'responds 200' do
      get new_admin_live_path

      expect(response).to have_http_status :ok
    end
  end

  describe 'POST /admin/lives' do
    context 'with valid params' do
      let(:params) do
        {
          live: {
            date: date.to_s,
            name: '6月ライブ',
            place: '4共21',
            album_url: '',
          },
        }
      end
      let(:date) { Time.zone.today }

      it 'creates a live and redirects to /admin/lives' do
        expect { post admin_lives_path, params: params }.to change(Live, :count).by(1)

        expect(response).to redirect_to admin_lives_path(year: date.nendo)
      end
    end

    context 'with invalid params' do
      let(:params) do
        {
          live: {
            date: '',
            name: '',
            place: '',
            album_url: '',
          },
        }
      end

      it 'responds 422' do
        expect { post admin_lives_path, params: params }.not_to change(Live, :count)

        expect(response).to have_http_status :unprocessable_entity
      end
    end
  end
end
