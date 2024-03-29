# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'admin/songs request:' do
  let(:admin) { create(:admin, scopes: %w[write:songs]) }

  before do
    log_in_as admin.user
  end

  describe 'GET /admin/lives/:live_id/songs/new' do
    let(:live) { create(:live) }

    it 'responds 200' do
      get new_admin_live_song_path(live)

      expect(response).to have_http_status :ok
    end
  end

  describe 'POST /admin/lives/:live_id/songs' do
    let(:live) { create(:live) }
    let(:member) { create(:member) }

    context 'with valid params' do
      let(:params) do
        {
          song: {
            position: '',
            name: 'ライディーン',
            artist: 'YMO',
            original: '0',
            youtube_url: '',
            plays_attributes: {
              '0' => {
                _destroy: '0',
                instrument: 'Key',
                member_id: member.id.to_s,
              },
            },
          },
        }
      end

      it 'creates a song and redirects to /admin/lives/:id' do
        expect { post admin_live_songs_path(live), params: }
          .to change(Song, :count).by(1).and change(Play, :count).by(1)
        expect(response).to redirect_to admin_live_path(live)
      end
    end

    context 'with invalid params' do
      let(:params) do
        {
          song: {
            position: '',
            name: '',
            artist: '',
            original: '0',
            youtube_url: '',
            plays_attributes: {
              '0' => {
                _destroy: '0',
                instrument: 'Key',
                member_id: member.id.to_s,
              },
            },
          },
        }
      end

      it 'responds 422' do
        expect { post admin_live_songs_path(live), params: }
          .to not_change(Song, :count).and not_change(Play, :count)
        expect(response).to have_http_status :unprocessable_entity
      end
    end
  end

  describe 'GET /admin/songs/:id/edit' do
    let(:song) { create(:song) }

    it 'responds 200' do
      get edit_admin_song_path(song)

      expect(response).to have_http_status :ok
    end
  end

  describe 'PATCH /admin/song/:id' do
    let(:song) { create(:song, name: 'before') }

    context 'with valid params' do
      let(:params) do
        {
          song: {
            live_id: song.live_id,
            position: song.position,
            name: 'after',
            artist: song.artist,
            original: song.original ? '1' : '0',
            youtube_url: song.youtube_url,
          },
        }
      end

      it 'updates the song and redirects to /admin/lives/:id' do
        patch(admin_song_path(song), params:)

        expect(song.reload.name).to eq 'after'
        expect(response).to redirect_to admin_live_path(song.live)
      end
    end

    context 'with invalid params' do
      let(:params) do
        {
          song: {
            live_id: song.live_id,
            position: song.position,
            name: '',
            artist: song.artist,
            original: song.original ? '1' : '0',
            youtube_url: song.youtube_url,
          },
        }
      end

      it 'responds 422' do
        patch(admin_song_path(song), params:)

        expect(song.reload.name).to eq 'before'
        expect(response).to have_http_status :unprocessable_entity
      end
    end
  end

  describe 'DELETE /admin/songs/:id' do
    let(:song) { create(:song) }

    before do
      allow(AdminActivityNotifyJob).to receive(:perform_now)
    end

    it 'destroys the song and redirects to /admin/lives/:id' do
      delete admin_song_path(song)

      expect(response).to redirect_to admin_live_path(song.live)
      expect { song.reload }.to raise_error ActiveRecord::RecordNotFound
    end
  end
end
