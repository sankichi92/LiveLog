require 'rails_helper'

RSpec.describe 'Api::V1::Users', type: :request do
  let(:user) { create(:user, public: public) }
  let!(:token) { create(:token, user: user) }

  describe 'GET /api/v1/members' do
    let(:public) { false }
    let(:expected_body) do
      [
        {
          id: user.id,
          joined: user.joined,
          public: user.public,
          name: user_name
        }
      ]
    end

    before { get api_v1_users_path, headers: headers }

    context 'with no token' do
      let(:headers) { nil }
      let(:user_name) { user.handle }

      it 'responds with valid status and json' do
        expect(response).to have_http_status(200)
        expect(response.body).to be_json_as(expected_body)
      end
    end

    context 'with valid token' do
      let(:headers) do
        { Authorization: "Token token=\"#{token.token}\", id=\"#{user.id}\"" }
      end
      let(:user_name) { user.name_with_handle }

      it 'responds with valid status and json' do
        expect(response).to have_http_status(200)
        expect(response.body).to be_json_as(expected_body)
      end
    end

    context 'with invalid token' do
      let(:invalid_token) { Token.random }
      let(:headers) do
        { Authorization: "Token token=\"#{invalid_token}\", id=\"#{user.id}\"" }
      end
      let(:user_name) { user.handle }

      it 'responds with valid status and json' do
        expect(response).to have_http_status(200)
        expect(response.body).to be_json_as(expected_body)
      end
    end
  end

  describe 'GET /api/v1/members/:id' do
    let(:live) { create(:live) }
    let(:song) { create(:song, live: live, status: :closed) }
    let!(:playing) { create(:playing, user: user, song: song, inst: 'Gt') }
    let(:expected_body) do
      {
        id: user.id,
        joined: user.joined,
        public: user.public,
        url: user.url,
        intro: user.intro,
        name: user_name,
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
            youtube_id: youtube_id,
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
    let(:token) { create(:token) }

    before { get api_v1_user_path(user), headers: headers }

    context 'with no token' do
      let(:headers) { nil }

      context 'when user.public == true' do
        let(:public) { true }
        let(:user_name) { user.handle }
        let(:youtube_id) { '' }

        it 'responds with valid status and json' do
          expect(response).to have_http_status(200)
          expect(response.body).to be_json_as(expected_body)
        end
      end

      context 'when user.public == false' do
        let(:public) { false }

        it { expect(response).to have_http_status(401) }
      end
    end

    context 'with valid token' do
      let(:headers) do
        { Authorization: "Token token=\"#{token.token}\", id=\"#{token.user.id}\"" }
      end
      let(:public) { false }
      let(:user_name) { user.name_with_handle }
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

      context 'when user.public == true' do
        let(:public) { true }
        let(:user_name) { user.handle }
        let(:youtube_id) { '' }

        it 'responds with valid status and json' do
          expect(response).to have_http_status(200)
          expect(response.body).to be_json_as(expected_body)
        end
      end

      context 'when user.public == false' do
        let(:public) { false }

        it { expect(response).to have_http_status(401) }
      end
    end
  end
end
