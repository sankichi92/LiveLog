# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'GraphQL query: songs', type: :graphql do
  subject(:result) { LiveLogSchema.execute(query) }

  let(:query) do
    <<~GRAPHQL
      query {
        songs {
          nodes {
            id
          }
        }
      }
    GRAPHQL
  end

  before do
    create_list(:song, 3)
  end

  it 'returns SongConnection' do
    expect(result.to_h).not_to include('errors')
    expect(result['data']['songs']['nodes'].size).to eq 3
  end
end
