require 'rails_helper'

RSpec.describe 'Api::V1::Songs', type: :request do
  let(:live) { create(:live) }
  let!(:song) { create(:song, status: :open, live: live) }

  describe 'GET /api/v1/songs' do
    let(:expected_body) do
      [
        {
          id: song.id,
          name: song.name,
          artist: song.artist,
          order: song.order,
          time: song.time_str,
          youtube_id: song.youtube_id,
          live: {
            id: live.id,
            name: live.name,
            date: live.date.to_s,
            place: live.place
          }
        }
      ]
    end

    before { get api_v1_songs_path }

    it 'responds with valid json' do
      expect(response).to have_http_status(200)
      expect(response.body).to be_json_as(expected_body)
    end
  end

  describe 'GET /api/v1/songs/:id' do
    let(:user) { create(:user) }
    let!(:playing) { create(:playing, song: song, user: user) }
    let(:expected_body) do
      {
        id: song.id,
        name: song.name,
        artist: song.artist,
        order: song.order,
        time: song.time_str,
        youtube_id: song.youtube_id,
        comment: song.comment,
        live: {
          id: live.id,
          name: live.name,
          date: live.date.to_s,
          place: live.place
        },
        playings: [
          inst: playing.inst,
          user: {
            id: user.id,
            joined: user.joined,
            public: user.public,
            name: user.handle
          }
        ]
      }
    end

    before { get api_v1_song_path(song) }

    it 'responds with valid json' do
      expect(response).to have_http_status(200)
      expect(response.body).to be_json_as(expected_body)
    end
  end
end
