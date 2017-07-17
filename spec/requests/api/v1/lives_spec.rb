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

    it 'responds with valid json' do
      expect(response).to have_http_status(200)
      expect(response.body).to be_json_as(expected_body)
    end
  end

  describe 'GET /api/v1/lives/:id' do
    let(:song) { create(:song, live: live) }
    let(:user) { create(:user) }
    let!(:playing) { create(:playing, user: user, song: song) }
    let(:expected_body) do
      {
        id: live.id,
        name: live.name,
        date: live.date.to_s,
        place: live.place,
        songs: [
          {
            id: song.id,
            name: song.name,
            artist: song.artist,
            order: song.order,
            time: song.time_str,
            youtube_id: ''
          }
        ]
      }
    end

    before { get api_v1_live_path(live) }

    it 'responds with valid json' do
      expect(response).to have_http_status(200)
      expect(response.body).to be_json_as(expected_body)
    end
  end
end
