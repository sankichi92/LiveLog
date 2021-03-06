# frozen_string_literal: true

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

    let(:joined_year) { 2020 }
    let(:members) { create_pair(:member, joined_year: joined_year) }

    before do
      create(:song, members: [members.first])
    end

    it 'returns MemberConnection' do
      expected_data = {
        members: {
          nodes: members.map do |member|
            {
              id: member.id.to_s,
            }
          end,
        },
      }

      expect(result.keys).to contain_exactly 'data'
      expect(result['data']).to eq expected_data.deep_stringify_keys
    end
  end
end
