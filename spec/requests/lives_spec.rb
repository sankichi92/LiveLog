require 'rails_helper'

RSpec.describe 'Lives', type: :request do
  let!(:live) { create(:live) }

  describe 'GET /lives.json' do
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

    before { get lives_path, as: :json }

    it_behaves_like 'valid response'
  end

  describe 'GET /lives/:id.json' do
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
            time: song.time
          }
        ]
      }
    end

    before { get live_path(live), as: :json }

    it_behaves_like 'valid response'
  end
end
