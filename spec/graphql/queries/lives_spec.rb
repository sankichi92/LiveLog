require 'rails_helper'

RSpec.describe 'GraphQL query:', type: :graphql do
  describe 'lives' do
    let!(:lives) { create_pair(:live) }
    let(:query) do
      <<~GRAPHQL
        query {
          lives {
            nodes {
              id
            }
          }
        }
      GRAPHQL
    end

    it 'returns LiveConnection' do
      result = LiveLogSchema.execute(query, context: graphql_context)

      expect(result['data']['lives']['nodes'].map { |live| live['id'].to_i }).to match_array lives.map(&:id)
    end
  end
end
