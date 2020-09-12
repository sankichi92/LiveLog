# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'GraphQL query:', type: :graphql do
  describe 'songs' do
    subject(:result) { LiveLogSchema.execute(query, variables: variables, context: context) }

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
    let(:variables) { {} }
    let(:context) { graphql_context }

    let!(:songs) { create_pair(:song) }

    it 'returns SongConnection' do
      expect(result.keys).to contain_exactly 'data'
      expect(result['data']['songs']['nodes'].map { |song| song['id'].to_i }).to match_array songs.map(&:id)
    end
  end
end
