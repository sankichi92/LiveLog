require 'rails_helper'

RSpec.describe 'songs request:', type: :request do
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

  describe 'GET /songs/:id/edit' do
    let(:song) { create(:song) }
    let(:user) { create(:user) }

    before do
      log_in_as user
    end

    context 'when the current_user is a player of the song' do
      before do
        create(:play, song: song, member: user.member)
      end

      it 'responds 200' do
        get edit_song_path(song)

        expect(response).to have_http_status :ok
      end
    end

    context 'when the current_user is NOT a player of the song' do
      it 'redirects with alert' do
        get edit_song_path(song)

        expect(response).to have_http_status :redirect
        expect(flash.alert).to eq '権限がありません'
      end
    end
  end

  describe 'PATCH /songs/:id' do
    let(:song) { create(:song, name: 'before', members: [user.member]) }
    let(:user) { create(:user) }
    let(:params) do
      {
        song: {
          name: song_name,
          artist: song.artist,
          original: song.original,
          visibility: song.visibility,
          comment: song.comment,
        },
      }
    end

    before do
      log_in_as user
    end

    context 'with valid params' do
      let(:song_name) { 'after' }

      it 'updates the song and redirects to /songs/:id' do
        patch song_path(song), params: params

        expect(song.reload.name).to eq song_name
        expect(response).to redirect_to(song)
      end
    end

    context 'with invalid params' do
      let(:song_name) { '' }

      it 'responds 422' do
        patch song_path(song), params: params

        expect(song.reload.name).not_to eq song_name
        expect(response).to have_http_status :unprocessable_entity
      end
    end
  end
end
