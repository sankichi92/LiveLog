# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'GraphQL query: members', type: :graphql do
  subject(:result) { LiveLogSchema.execute(query, variables:) }

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

  let(:joined_year) { 2020 }

  before do
    create_list(:member, 3, joined_year:)
  end

  it 'returns members' do
    expect(result.to_h).not_to include('errors')
    expect(result['data']['members']['nodes'].size).to eq 3
  end
end
