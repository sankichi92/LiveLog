# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'GraphQL query: live', type: :graphql do
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
  let(:variables) { { id: LiveLogSchema.id_from_object(live, Types::LiveType) } }
  let(:context) { { auth_payload: { scope: scope } } }

  let(:live) { create(:live) }
  let(:scope) { '' }

  before do
    create_list(:song, 3, live: live)
  end

  it 'returns a live' do
    expect(result.to_h).not_to include('errors')
    expect(result['data'].deep_symbolize_keys).to match(
      {
        live: {
          id: String,
          date: live.date.iso8601,
          name: live.name,
          place: live.place,
          comment: live.comment,
          songs: {
            nodes: [
              { id: String },
              { id: String },
              { id: String },
            ],
          },
        },
      },
    )
  end

  context 'with albumUrl' do
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
      expect(result.to_h).to include('errors')
      expect(result['errors'][0]['message']).to eq "Field 'albumUrl' doesn't exist on type 'Live'"
    end

    context 'with read:lives scope' do
      let(:scope) { 'read:lives' }

      it 'returns a live with albumUrl' do
        expect(result.to_h).not_to include('errors')
        expect(result['data']['live']['albumUrl']).to eq live.album_url
      end
    end
  end
end
