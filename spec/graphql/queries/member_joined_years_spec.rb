# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'GraphQL query: memberJoinedYears', type: :graphql do
  subject(:result) { LiveLogSchema.execute(query) }

  let(:query) do
    <<~GRAPHQL
      query {
        memberJoinedYears
      }
    GRAPHQL
  end

  before do
    create(:member, joined_year: 2020)
    create(:member, joined_year: 2019)
  end

  it 'returns joined_years Int array' do
    expect(result.to_h).not_to include('errors')
    expect(result['data'].deep_symbolize_keys).to eq(
      {
        memberJoinedYears: [
          2020,
          2019,
        ],
      },
    )
  end
end
