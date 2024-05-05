# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'lives request:' do
  describe 'GET /lives' do
    it 'responds 200' do
      get lives_path

      expect(response).to have_http_status(:ok)
    end
  end

  describe 'GET /lives/:id' do
    let(:live) { create(:live) }

    before do
      create_pair(:song, live:, members: create_pair(:member))
    end

    it 'responds 200' do
      get live_path(live)

      expect(response).to have_http_status(:ok)
    end
  end

  describe 'GET /lives/:id/album' do
    before do
      log_in_as create(:user)
    end

    context 'when the album_url is present' do
      let(:live) { create(:live, album_url: 'https://example.com/album') }

      it 'redirects to album_url' do
        get album_live_path(live)

        expect(response).to redirect_to live.album_url
      end
    end

    context 'when the album_url is blank' do
      let(:live) { create(:live, album_url: '') }

      it 'responds 404' do
        get album_live_path(live)

        expect(response).to have_http_status(:not_found)
      end
    end
  end
end
