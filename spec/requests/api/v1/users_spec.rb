require 'rails_helper'

RSpec.describe 'Api::V1::Users', type: :request do
  let(:token) { User.new_token }
  let!(:user) { create(:user, public: public, api_digest: User.digest(token)) }

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
        { Authorization: "Token token=\"#{token}\", id=\"#{user.id}\"" }
      end
      let(:user_name) { user.full_name }

      it 'responds with valid status and json' do
        expect(response).to have_http_status(200)
        expect(response.body).to be_json_as(expected_body)
      end
    end

    context 'with invalid token' do
      let(:invalid_token) { User.new_token }
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
    let(:song) { create(:song, live: live) }
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
      let(:token) { User.new_token }
      let(:visitor) { create(:user, api_digest: User.digest(token)) }
      let(:headers) do
        { Authorization: "Token token=\"#{token}\", id=\"#{visitor.id}\"" }
      end
      let(:public) { false }
      let(:user_name) { user.full_name }
      let(:youtube_id) { song.youtube_id }

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
