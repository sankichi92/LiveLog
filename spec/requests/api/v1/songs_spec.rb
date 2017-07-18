require 'rails_helper'

RSpec.describe 'Api::V1::Songs', type: :request do
  let(:live) { create(:live) }
  let!(:song) { create(:song, live: live) }

  describe 'GET /api/v1/songs' do
    let(:expected_body) do
      [
        {
          id: song.id,
          name: song.name,
          artist: song.artist,
          order: song.order,
          time: song.time_str,
          youtube_id: youtube_id,
          live: {
            id: live.id,
            name: live.name,
            date: live.date.to_s,
            place: live.place
          }
        }
      ]
    end

    before { get api_v1_songs_path, headers: headers }

    context 'with no token' do
      let(:headers) { nil }
      let(:youtube_id) { '' }

      it 'responds with valid status and json' do
        expect(response).to have_http_status(200)
        expect(response.body).to be_json_as(expected_body)
      end
    end

    context 'with valid token' do
      let(:token) { User.new_token }
      let(:user) { create(:user, api_digest: User.digest(token)) }
      let(:headers) do
        { Authorization: "Token token=\"#{token}\", id=\"#{user.id}\"" }
      end
      let(:youtube_id) { song.youtube_id }

      it 'responds with valid status and json' do
        expect(response).to have_http_status(200)
        expect(response.body).to be_json_as(expected_body)
      end
    end

    context 'with invalid token' do
      let(:invalid_token) { User.new_token }
      let(:user) { create(:user) }
      let(:headers) do
        { Authorization: "Token token=\"#{invalid_token}\", id=\"#{user.id}\"" }
      end
      let(:youtube_id) { '' }

      it 'responds with valid status and json' do
        expect(response).to have_http_status(200)
        expect(response.body).to be_json_as(expected_body)
      end
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
        youtube_id: youtube_id,
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
            name: user_name
          }
        ]
      }
    end

    before { get api_v1_song_path(song), headers: headers }

    context 'with no token' do
      let(:headers) { nil }
      let(:youtube_id) { '' }
      let(:user_name) { user.handle }

      it 'responds with valid status and json' do
        expect(response).to have_http_status(200)
        expect(response.body).to be_json_as(expected_body)
      end
    end

    context 'with valid token' do
      let(:token) { User.new_token }
      let(:visitor) { create(:user, api_digest: User.digest(token)) }
      let(:headers) do
        { Authorization: "Token token=\"#{token}\", id=\"#{visitor.id}\"" }
      end
      let(:youtube_id) { song.youtube_id }
      let(:user_name) { user.full_name }

      it 'responds with valid status and json' do
        expect(response).to have_http_status(200)
        expect(response.body).to be_json_as(expected_body)
      end
    end

    context 'with invalid token' do
      let(:invalid_token) { User.new_token }
      let(:visitor) { create(:user) }
      let(:headers) do
        { Authorization: "Token token=\"#{invalid_token}\", id=\"#{visitor.id}\"" }
      end
      let(:youtube_id) { '' }
      let(:user_name) { user.handle }

      it 'responds with valid status and json' do
        expect(response).to have_http_status(200)
        expect(response.body).to be_json_as(expected_body)
      end
    end
  end
end
