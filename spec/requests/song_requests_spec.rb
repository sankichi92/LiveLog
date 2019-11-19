require 'rails_helper'

RSpec.describe 'Song requests', type: :request do
  describe 'GET /songs' do
    before do
      create_pair(:song, members: create_pair(:member))
    end

    it 'responds 200' do
      get songs_path

      expect(response).to have_http_status(:ok)
    end
  end

  describe 'GET /songs/search' do
    context 'with valid params' do
      let(:query) { 'The Beatles' }
      let(:params) { { q: query } }

      before do
        create(:song, artist: query)
        create(:song)
      end

      it 'responds 200' do
        get search_songs_path, params: params

        expect(response).to have_http_status(:ok)
      end
    end

    context 'with invalid params' do
      let(:search_params) { { media: 'invalid' } }

      it 'responds 422' do
        get search_songs_path, params: search_params

        expect(response).to have_http_status(:unprocessable_entity)
      end
    end
  end

  describe 'GET /songs/:id' do
    let(:song) { create(:song, members: create_pair(:member)) }

    it 'responds 200' do
      get search_songs_path(song)

      expect(response).to have_http_status(:ok)
    end
  end

  describe 'GET /songs/new by admin' do
    let(:live) { create(:live) }

    before { log_in_as(create(:admin)) }

    it 'responds 200' do
      get new_song_path, params: { live_id: live.id }
      expect(response).to have_http_status(:ok)
    end
  end

  describe 'POST /songs by admin' do
    let(:live) { create(:live) }

    before { log_in_as(create(:admin)) }

    context 'with valid params' do
      let(:song_attrs) { attributes_for(:song, live_id: live.id) }

      it 'creates a song and redirects to /song/:id' do
        expect { post songs_path, params: { song: song_attrs } }.to change(Song, :count).by(1)
        expect(response).to redirect_to(Song.last.live)
      end
    end

    context 'with invalid params' do
      let(:song_attrs) { attributes_for(:song, :invalid, live_id: live.id) }

      it 'responds 422' do
        expect { post songs_path, params: { song: song_attrs } }.not_to change(Song, :count)
        expect(response).to have_http_status(:unprocessable_entity)
      end
    end
  end

  describe 'GET /songs/:id/edit by player' do
    let(:song) { create(:song, members: [user.member]) }
    let(:user) { create(:user) }

    before do
      log_in_as(user)
    end

    it 'responds 200' do
      get edit_song_path(song)

      expect(response).to have_http_status(:ok)
    end
  end

  describe 'PATCH /songs/:id by player' do
    let(:song) { create(:song) }

    before { log_in_as(create(:user, songs: [song])) }

    context 'with valid params' do
      let(:new_song_attrs) { attributes_for(:song, name: 'updated song') }

      it 'updates the song and redirects to /songs/:id' do
        patch song_path(song), params: { song: new_song_attrs }
        expect(response).to redirect_to(song)
        expect(song.reload.name).to eq 'updated song'
      end
    end

    context 'with invalid params' do
      let(:new_song_attrs) { attributes_for(:song, name: '') }

      it 'responds 422' do
        patch song_path(song), params: { song: new_song_attrs }
        expect(response).to have_http_status(:unprocessable_entity)
        expect(song.reload.name).not_to eq ''
      end
    end
  end

  describe 'DELETE /songs/:id by admin' do
    let!(:song) { create(:song) }

    before { log_in_as(create(:admin)) }

    it 'deletes the song and redirects /lives/:id' do
      expect { delete song_path(song) }.to change(Song, :count).by(-1)
      expect(response).to redirect_to(song.live)
    end
  end
end
