require 'rails_helper'

RSpec.describe 'Live requests', type: :request do
  describe 'GET /lives' do
    it 'responds 200' do
      get lives_path
      expect(response).to have_http_status(:ok)
    end
  end

  describe 'GET /lives/:id' do
    context 'when the live is published' do
      let(:live) { create(:live) }

      it 'responds 200' do
        get live_path(live)
        expect(response).to have_http_status(:ok)
      end
    end

    context 'when the live is unpublished' do
      let(:live) { create(:live, :draft) }

      it 'redirects to /lives/:id/entries' do
        get live_path(live)
        expect(response).to redirect_to(live_entries_url(live))
      end
    end
  end

  describe 'GET /lives/:id/album by logged-in user' do
    before { log_in_as(create(:user), capybara: false) }

    context 'when the album_url is present' do
      let(:live) { create(:live) }

      it 'redirects to album_url' do
        get album_live_path(live)
        expect(response).to redirect_to(live.album_url)
      end
    end

    context 'when the album_url is blank' do
      let(:live) { create(:live, album_url: '') }

      it 'redirects to album_url' do
        get album_live_path(live)
        expect(response).to redirect_to(live)
      end
    end
  end

  describe 'GET /lives/new by admin' do
    before { log_in_as(create(:admin), capybara: false) }

    it 'responds 200' do
      get new_live_path
      expect(response).to have_http_status(:ok)
    end
  end

  describe 'POST /lives by admin' do
    before { log_in_as(create(:admin), capybara: false) }

    context 'with valid params' do
      let(:live_attrs) { attributes_for(:live) }

      it 'creates a live and redirects to /live/:id' do
        expect { post lives_path, params: { live: live_attrs } }.to change(Live, :count).by(1)
        expect(response).to redirect_to(Live.last)
      end
    end

    context 'with invalid params' do
      let(:live_attrs) { attributes_for(:live, :invalid) }

      it 'responds 422' do
        expect { post lives_path, params: { live: live_attrs } }.not_to change(Live, :count)
        expect(response).to have_http_status(:unprocessable_entity)
      end
    end
  end

  describe 'GET /lives/:id/edit by admin' do
    let(:live) { create(:live) }

    before { log_in_as(create(:admin), capybara: false) }

    it 'responds 200' do
      get edit_live_path(live)
      expect(response).to have_http_status(:ok)
    end
  end

  describe 'PATCH /lives/:id by admin' do
    let(:live) { create(:live) }

    before { log_in_as(create(:admin), capybara: false) }

    context 'with valid params' do
      let(:new_live_attrs) { attributes_for(:live, name: 'updated live') }

      it 'updates the live and redirects to /lives/:id' do
        patch live_path(live), params: { live: new_live_attrs }
        expect(response).to redirect_to(live)
        expect(live.reload.name).to eq 'updated live'
      end
    end

    context 'with invalid params' do
      let(:new_live_attrs) { attributes_for(:live, name: '') }

      it 'responds 422' do
        patch live_path(live), params: { live: new_live_attrs }
        expect(response).to have_http_status(:unprocessable_entity)
        expect(live.reload.name).not_to eq ''
      end
    end
  end

  describe 'PUT /lives/:id/publish by admin' do
    before { log_in_as(create(:admin), capybara: false) }

    context 'when live is published' do
      let(:live) { create(:live) }

      it 'redirects to /lives/:id' do
        expect(TweetJob).not_to receive(:perform_now)
        put publish_live_url(live)
        expect(response).to redirect_to(live)
      end
    end

    context 'when live is unpublished' do
      let(:live) { create(:live, :draft) }

      before { Song.__elasticsearch__.create_index! }

      it 'publishes live, tweet it and redirects to /lives/:id' do
        expect(TweetJob).to receive(:perform_now)
        put publish_live_url(live)
        expect(response).to redirect_to(live)
        expect(live.reload.published).to be true
      end
    end
  end

  describe 'DELETE /lives/:id by admin' do
    let!(:live) { create(:live) }

    before { log_in_as(create(:admin), capybara: false) }

    context 'when the live has no songs' do
      it 'deletes the song and redirects to /lives' do
        expect { delete live_path(live) }.to change(Live, :count).by(-1)
        expect(response).to redirect_to(lives_url)
      end
    end

    context 'when the live has one or more songs' do
      before { create(:song, live: live) }

      it 'responds 422' do
        expect { delete live_path(live) }.not_to change(Live, :count)
        expect(response).to have_http_status(:unprocessable_entity)
      end
    end
  end
end
