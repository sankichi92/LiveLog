require 'rails_helper'

RSpec.describe 'GraphQL query:', type: :graphql do
  describe 'songs' do
    let!(:songs) { create_pair(:song) }
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

    it 'returns LiveConnection' do
      result = LiveLogSchema.execute(query, context: graphql_context)

      expect(result['data']['songs']['nodes'].map { |song| song['id'].to_i }).to match_array songs.map(&:id)
    end
  end
end
