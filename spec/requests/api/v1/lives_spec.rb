require 'rails_helper'

RSpec.describe 'Api::V1::Lives', type: :request do
  let!(:live) { create(:live) }

  describe 'GET /api/v1/lives' do
    let(:expected_body) do
      [
        {
          id: live.id,
          name: live.name,
          date: live.date.to_s,
          place: live.place
        }
      ]
    end

    before { get api_v1_lives_path }

    it 'responds with valid status and json' do
      expect(response).to have_http_status(200)
      expect(response.body).to be_json_as(expected_body)
    end
  end

  describe 'GET /api/v1/lives/:id' do
    let(:user) { create(:user) }
    let(:song) { create(:song, live: live) }
    let!(:playing) { create(:playing, user: user, song: song) }
    let(:expected_body) do
      {
        id: live.id,
        name: live.name,
        date: live.date.to_s,
        place: live.place,
        album_url: live.album_url,
        songs: [
          {
            id: song.id,
            name: song.name,
            artist: song.artist,
            order: song.order,
            time: song.time_str,
            youtube_id: youtube_id
          }
        ]
      }
    end
    let(:token) { create(:token) }

    before { get api_v1_live_path(live), headers: headers }

    context 'with no token' do
      let(:headers) { nil }
      let(:youtube_id) { '' }

      it 'responds with valid status and json' do
        expect(response).to have_http_status(200)
        expect(response.body).to be_json_as(expected_body)
      end
    end

    context 'with valid token' do
      let(:headers) do
        { Authorization: "Token token=\"#{token.token}\", id=\"#{token.user.id}\"" }
      end
      let(:youtube_id) { song.youtube_id }

      it 'responds with valid status and json' do
        expect(response).to have_http_status(200)
        expect(response.body).to be_json_as(expected_body)
      end
    end

    context 'with invalid token' do
      let(:invalid_token) { create(:token) }
      let(:headers) do
        { Authorization: "Token token=\"#{invalid_token.token}\", id=\"#{token.user.id}\"" }
      end
      let(:youtube_id) { '' }

      it 'responds with valid status and json' do
        expect(response).to have_http_status(200)
        expect(response.body).to be_json_as(expected_body)
      end
    end
  end
end
