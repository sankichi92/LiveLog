require 'rails_helper'

RSpec.describe 'Api::V1::Users', type: :request do
  let!(:user) { create(:user, public: true) }

  describe 'GET /api/v1/members' do
    let(:expected_body) do
      [
        {
          id: user.id,
          joined: user.joined,
          public: user.public,
          name: user.handle
        }
      ]
    end

    before { get api_v1_users_path }

    it 'responds with valid json' do
      expect(response).to have_http_status(200)
      expect(response.body).to be_json_as(expected_body)
    end
  end

  describe 'GET /api/v1/members/:id' do
    let(:live) { create(:live) }
    let(:song) { create(:song, live: live) }
    let!(:playing) { create(:playing, user: user, song: song, inst: 'Gt') }
    let(:expected_body) do
      {
        id: user.id,
        joined: user.joined,
        public: user.public,
        url: user.url,
        intro: user.intro,
        name: user.handle,
        insts: [
          {
            inst: playing.inst,
            count: 1
          }
        ],
        songs: [
          {
            id: song.id,
            name: song.name,
            artist: song.artist,
            order: song.order,
            time: song.time_str,
            youtube_id: '',
            live: {
              id: live.id,
              name: live.name,
              date: live.date.to_s,
              place: live.place
            }
          }
        ]
      }
    end

    before { get api_v1_user_path(user) }

    it 'responds with valid json' do
      expect(response).to have_http_status(200)
      expect(response.body).to be_json_as(expected_body)
    end
  end
end
