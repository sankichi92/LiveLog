require 'rails_helper'

RSpec.describe 'lives request:', type: :request do
  describe 'GET /lives' do
    it 'responds 200' do
      get lives_path

      expect(response).to have_http_status(:ok)
    end
  end

  describe 'GET /lives/:id' do
    context 'when the live is published' do
      let(:live) { create(:live) }

      before do
        create_pair(:song, live: live, members: create_pair(:member))
      end

      it 'responds 200' do
        get live_path(live)

        expect(response).to have_http_status(:ok)
      end
    end

    context 'when the live is unpublished' do
      let(:live) { create(:live, :unpublished) }

      it 'redirects to /lives/:id/entries' do
        get live_path(live)

        expect(response).to redirect_to(live_entries_url(live))
      end
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

      it 'raises ActionController::RoutingError' do
        expect { get album_live_path(live) }.to raise_error(ActionController::RoutingError)
      end
    end
  end
end
