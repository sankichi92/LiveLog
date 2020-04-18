require 'rails_helper'

RSpec.describe 'GraphQL query:', type: :graphql do
  describe 'song' do
    subject(:result) { LiveLogSchema.execute(query, variables: variables, context: context) }

    let(:query) do
      <<~GRAPHQL
        query($id: ID!) {
          song(id: $id) {
            id
            time
            order
            name
            artist
            original
            comment
            live {
              id
            }
            players {
              edges {
                instrument
                node {
                  id
                }
              }
            }
          }
        }
      GRAPHQL
    end
    let(:variables) { { id: song.id } }
    let(:context) { graphql_context(scope: scope) }

    let(:song) { create(:song, visibility: :only_logged_in_users, youtube_url: 'https://www.youtube.com/watch?v=2TL90rxt9bo') }
    let!(:play) { create(:play, song: song) }
    let(:scope) { '' }

    it 'returns Song' do
      expected_data = {
        song: {
          id: song.id.to_s,
          time: song.time_str,
          order: song.position,
          name: song.name,
          artist: song.artist,
          original: song.original?,
          comment: song.comment,
          live: {
            id: song.live.id.to_s,
          },
          players: {
            edges: [
              {
                instrument: play.instrument,
                node: {
                  id: play.member.id.to_s,
                },
              },
            ],
          },
        },
      }

      expect(result.keys).to contain_exactly 'data'
      expect(result['data']).to eq expected_data.deep_stringify_keys
    end

    context 'with youtubeUrl field' do
      let(:query) do
        <<~GRAPHQL
          query($id: ID!) {
            song(id: $id) {
              youtubeUrl
            }
          }
        GRAPHQL
      end

      it 'returns empty youtubeUrl' do
        expect(result['data']['song']['youtubeUrl']).to be_nil
      end

      context 'with read:songs scope' do
        let(:scope) { 'read:songs' }

        it 'returns youtubeUrl' do
          expect(result['data']['song']['youtubeUrl']).to eq song.youtube_url
        end
      end
    end
  end
end
