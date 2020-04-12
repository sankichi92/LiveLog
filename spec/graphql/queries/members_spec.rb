require 'rails_helper'

RSpec.describe 'GraphQL query:', type: :graphql do
  describe 'members' do
    subject(:result) { LiveLogSchema.execute(query, variables: variables, context: context) }

    let(:query) do
      <<~GRAPHQL
        query($year: Int!) {
          members(year: $year) {
            nodes {
              id
            }
          }
        }
      GRAPHQL
    end
    let(:variables) { { year: joined_year } }
    let(:context) { graphql_context }

    let(:members) { create_pair(:member, joined_year: joined_year) }
    let(:joined_year) { 2020 }

    it 'returns MemberConnection' do
      expected_data = {
        members: {
          nodes: members.map { |member|
            {
              id: member.id.to_s,
            }
          },
        },
      }

      expect(result.keys).to contain_exactly 'data'
      expect(result['data']).to eq expected_data.deep_stringify_keys
    end
  end
end
