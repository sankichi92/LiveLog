require 'rails_helper'

RSpec.describe 'GraphQL query:', type: :graphql do
  describe 'member' do
    subject(:result) { LiveLogSchema.execute(query, variables: variables, context: context) }

    let(:query) do
      <<~GRAPHQL
        query($id: ID!) {
          member(id: $id) {
            id
            joinedYear
            name
            url
            bio
            playedSongs {
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
    let(:variables) { { id: member.id } }
    let(:context) { graphql_context }

    let(:member) { create(:member) }
    let!(:play) { create(:play, member: member) }

    it 'returns Member' do
      expected_data = {
        member: {
          id: member.id.to_s,
          joinedYear: member.joined_year,
          name: member.name,
          url: member.url,
          bio: member.bio,
          playedSongs: {
            edges: [
              {
                instrument: play.instrument,
                node: {
                  id: play.song.id.to_s,
                },
              },
            ],
          },
        },
      }

      expect(result.keys).to contain_exactly 'data'
      expect(result['data']).to eq expected_data.deep_stringify_keys
    end
  end
end
