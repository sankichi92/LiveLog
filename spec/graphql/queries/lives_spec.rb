# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'GraphQL query:', type: :graphql do
  describe 'lives' do
    subject(:result) { LiveLogSchema.execute(query, variables: variables, context: context) }

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
    let(:variables) { {} }
    let(:context) { graphql_context }

    let!(:lives) { create_pair(:live) }

    it 'returns LiveConnection' do
      expected_data = {
        lives: {
          nodes: lives.sort_by(&:date).reverse.map do |live|
            {
              id: live.id.to_s,
            }
          end,
        },
      }

      expect(result.keys).to contain_exactly 'data'
      expect(result['data']).to eq expected_data.deep_stringify_keys
    end
  end
end
