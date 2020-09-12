# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'GraphQL query:', type: :graphql do
  describe 'memberJoinedYears' do
    subject(:result) { LiveLogSchema.execute(query, variables: variables, context: context) }

    let(:query) do
      <<~GRAPHQL
        query {
          memberJoinedYears
        }
      GRAPHQL
    end
    let(:variables) { {} }
    let(:context) { graphql_context }

    before do
      create(:member, joined_year: 2020)
      create(:member, joined_year: 2019)
    end

    it 'returns joined_years Int array' do
      expected_data = {
        memberJoinedYears: [2020, 2019],
      }

      expect(result.keys).to contain_exactly 'data'
      expect(result['data']).to eq(expected_data.deep_stringify_keys)
    end
  end
end
