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
      let(:live) { create(:draft_live) }

      it 'redirects to /lives/:id/entries' do
        get live_path(live)
        expect(response).to redirect_to(live_entries_url(live))
      end
    end
  end

  describe 'GET /lives/:id/album' do
    let(:live) { create(:live) }

    context 'by a logged-in user' do
      before { log_in_as(create(:user), capybara: false) }

      context 'when the album_url is present' do
        it 'redirects to album_url' do
          get album_live_path(live)
          expect(response).to redirect_to(live.album_url)
        end
      end

      context 'when the album_url is blank' do
        let(:live) { create(:live, album_url: '') }

        it 'redirects to album_url' do
          get album_live_path(live)
          expect(response).to redirect_to(live_url(live))
        end
      end
    end
  end

  describe 'GET /lives/new' do
    context 'by an admin user' do
      before { log_in_as(create(:admin), capybara: false) }

      it 'responds 200' do
        get new_live_path
        expect(response).to have_http_status(:ok)
      end
    end
  end

  describe 'GET /lives/:id/edit' do
    let(:live) { create(:live) }

    context 'by an admin user' do
      before { log_in_as(create(:admin), capybara: false) }

      it 'responds 200' do
        get edit_live_path(live)
        expect(response).to have_http_status(:ok)
      end
    end
  end

  describe 'POST /lives' do
    let(:live_attrs) { attributes_for(:live) }

    context 'by an admin user' do
      before { log_in_as(create(:admin), capybara: false) }

      context 'with valid params' do
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
  end

  describe 'PATCH /lives/:id' do
    let(:live) { create(:live) }
    let(:new_live_attrs) { attributes_for(:live, name: 'updated live') }

    context 'by an admin user' do
      before { log_in_as(create(:admin), capybara: false) }

      context 'with valid params' do
        it 'updates the live and redirects to /lives/:id' do
          patch live_path(live), params: { live: new_live_attrs }
          expect(response).to redirect_to(live_url(live))
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
  end

  describe 'DELETE /lives/:id' do
    let!(:live) { create(:live) }

    context 'by an admin user' do
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
end
