require 'rails_helper'

RSpec.describe 'GraphQL query:', type: :graphql do
  describe 'live' do
    subject(:result) { LiveLogSchema.execute(query, variables: variables, context: context) }

    let(:query) do
      <<~GRAPHQL
        query($id: ID!) {
          live(id: $id) {
            id
            date
            name
            place
            comment
            songs {
              nodes {
                id
              }
            }
          }
        }
      GRAPHQL
    end
    let(:variables) { { id: live.id } }
    let(:context) { graphql_context(scope: scope) }

    let(:live) { create(:live) }
    let!(:songs) { create_pair(:song, live: live) }
    let(:scope) { '' }

    it 'returns Live' do
      expected_data = {
        live: {
          id: live.id.to_s,
          date: live.date.iso8601,
          name: live.name,
          place: live.place,
          comment: live.comment,
          songs: {
            nodes: songs.map do |song|
              {
                id: song.id.to_s,
              }
            end,
          },
        },
      }

      expect(result.keys).to contain_exactly 'data'
      expect(result['data']).to eq expected_data.deep_stringify_keys
    end

    context 'with albumUrl field' do
      let(:query) do
        <<~GRAPHQL
          query($id: ID!) {
            live(id: $id) {
              albumUrl
            }
          }
        GRAPHQL
      end

      it 'returns errors' do
        expect(result.keys).to contain_exactly 'errors'
      end

      context 'with read:lives scope' do
        let(:scope) { 'read:lives' }

        it 'returns albumUrl' do
          expect(result.keys).to contain_exactly 'data'
          expect(result['data']['live']['albumUrl']).to eq live.album_url
        end
      end
    end
  end
end
