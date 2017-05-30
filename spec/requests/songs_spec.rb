require 'rails_helper'

RSpec.describe 'Songs', type: :request do
  let(:live) { create(:live) }
  let!(:song) { create(:song, status: :open, live: live) }

  describe 'GET /songs.json' do
    let(:expected_body) do
      [
        {
          id: song.id,
          name: song.name,
          artist: song.artist,
          order: song.order,
          time: song.time,
          live: {
            id: live.id,
            name: live.name,
            date: live.date.to_s,
            place: live.place
          }
        }
      ]
    end

    before { get songs_path, as: :json }

    it_behaves_like 'valid response'
  end

  describe 'GET /songs/:id.json' do
    let(:user) { create(:user) }
    let!(:playing) { create(:playing, song: song, user: user) }
    let(:expected_body) do
      {
        id: song.id,
        name: song.name,
        artist: song.artist,
        order: song.order,
        time: song.time,
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

    before { get song_path(song), as: :json }

    it_behaves_like 'valid response'
  end
end
