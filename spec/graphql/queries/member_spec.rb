# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'GraphQL query: member', type: :graphql do
  subject(:result) { LiveLogSchema.execute(query, variables: variables) }

  let(:query) do
    <<~GRAPHQL
      query($id: ID!) {
        member(id: $id) {
          id
          joinedYear
          name
          url
          bio
          avatarUrl
          playedInstruments
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
  let(:variables) { { id: LiveLogSchema.id_from_object(member, Types::MemberType) } }

  let(:member) { create(:member, avatar: create(:avatar)) }
  let!(:play) { create(:play, member: member) }

  it 'returns a member' do
    expect(result.to_h).not_to include('errors')
    expect(result['data'].deep_symbolize_keys).to match(
      {
        member: {
          id: String,
          joinedYear: member.joined_year,
          name: member.name,
          url: member.url,
          bio: member.bio,
          avatarUrl: member.avatar.image_url,
          playedInstruments: Array,
          playedSongs: {
            edges: [
              {
                instrument: play.instrument,
                node: {
                  id: String,
                },
              },
            ],
          },
        },
      },
    )
  end
end
