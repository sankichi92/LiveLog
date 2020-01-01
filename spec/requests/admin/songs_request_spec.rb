require 'rails_helper'

RSpec.describe 'admin/songs request:', type: :request do
  let(:admin) { create(:admin) }

  before do
    log_in_as admin
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
            playings_attributes: {
              '0' => {
                _destroy: '0',
                inst: 'Key',
                member_id: member.id.to_s,
              },
            },
          },
        }
      end

      it 'creates a song and redirects to /admin/lives/:id' do
        expect { post admin_live_songs_path(live), params: params }
          .to change(Song, :count).by(1).and change(Playing, :count).by(1)
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
            playings_attributes: {
              '0' => {
                _destroy: '0',
                inst: 'Key',
                member_id: member.id.to_s,
              },
            },
          },
        }
      end

      it 'responds 422' do
        expect { post admin_live_songs_path(live), params: params }
          .to change(Song, :count).by(0).and change(Playing, :count).by(0)
        expect(response).to have_http_status :unprocessable_entity
      end
    end
  end
end
